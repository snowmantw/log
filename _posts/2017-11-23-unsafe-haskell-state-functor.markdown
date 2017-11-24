---
layout: post
title: "unsafeMemo: State Functor"
date: 2017-11-23 15:47:00 +0900
categories: Haskell unsafeMemo
---

State Monad is weird, but State Functor is...weird and FUN.

## Functor (State s)

<img style="border: 2px solid #bbb" src="https://docs.google.com/drawings/d/e/2PACX-1vSsiSa4A9yOu0XpnORj6zMtpuxRyZGQeAG9jnxsD3-qikKutT62Uvr_hpH1Yx0neU0_tuH8MvJH-pM-/pub?w=960&amp;h=720">

**In brief**:

1. For this definition it is easy to image that it provide user to interact with the state and the output in previous step. One thing to note is that although it seems the same with the `(->) r a` Functor,
the real definition is actually `newtype State s a = State { runState :: s -> (s, a) }`. That means, the actual instance will be: `State (s -> (a, s))`. Compare to `Maybe a` or `(-> r) a`,
this is not easy to get the idea at the first look. The key is, there are two functions the user will provide for the computation: the `s -> (a, s)` and `(a -> b)`

2. A common example for tutorials is `State RandGen Int` that to generate a new `Int` from a random number generator. For each time it generates a random number, the generator need to be updated to prevent generating the same
number. Therefore, here we have the type `RandGen` as the implicit `s` in State Functor after every transformation step.

3. For the "embedding" Functors, the type signature is curried. So for definition like `Functor f => fmap:: (a->b) -> f a -> f b`, the `f` is `State s`, not `State`.

4. The embedded Functor parameter `RandGen`, although it doesn't appear in the `fmap` transformation for `a -> b`, still will be transformed as the value `Int` during the computation.

5. How the embedded parameter being transformed is defined by the `fmap` implementation. Since from the signature of `fmap`, there is no way to know how the `f`, namely `State s` is changed.
Therefore, for embedding Functors, the user must read more details in documents and maybe the implementation to know how to use the Functor properly.

### In Detail

For non-embedding Functor, like `Maybe a`, the transformation is transparent:

```haskell

let ma = Just Int -- Maybe a
let mb = fmap isOdd ma -- Maybe b

```

There is no other transformation during the `fmap`. However, for `State s a`, apparently there must be two transformations:


```haskell

fmap f (State g)

g :: s -> (a, s1) -- transformer for the state `s`, and generate the value `a` from `s`
f :: a -> b       -- transform the value generated; nothing to do with the state

```

The `fmap` will apply the embedding `g` first to perform state transformation, and then `f` for the value transformation. How to make different values from `f` is obvious, but how to control state transformation is not defined in `fmap`.
In fact, one needs to define the state transformer when defining the Functor before applying the `fmap`:

```haskell

-- Assume we are make a String stack with list: []
type Stack = []

-- `pop` and `push` are State transformers, so it will
-- nether be applied in `fmap` nor touch the value in the stack

pop :: State Stack String
pop = state (\(top:xs) -> (top, xs))

push :: String -> State Stack ()
push str = state (\xs -> ((), str:xs))

```

**Note**: The `state` function replaced the State constructor for [some reasons][2], but they are almost the same. 

In the example there are two state transformer that will manipulate the embedding `s` of `State s a`, while now the `s` is instantiated as `Stack` and `a` is `String`. Note that the each state manipulator is actually generating a new
Functor of `State s a`, while this means two things:

1. We instantiated two `State s a` functors via defining the state transformers.
2. We haven't defined the value transformer yet

The 1. actually reveals that we are not just defining a State data structure like `Maybe a` or `[] a`: we define the State Functor via defining how we use it. Therefore, the very nature way we can put the initial state at the beginning of the
state computation is to define an "init" transformer:

```haskell

put :: s -> State s a
put s = state (\s -> ((), s))

-- for the stack example:

let init = put []

```

This means to transform the state to have one empty stack at the beginning.

The 2. reveals that we now actually have two phase to compose our State computation. We first define how the state get initialised and transformed during the computation, and then we use the defined computation with actual value transformers
to get the final result. For example, we can define a computation like this (in GHCi):

```haskell

-- value transformer
let barToApple = \bar -> "apple"

-- the computation with defined state transformers `pop`, `push` and `init`;
-- looks horrible since we don't have Monad yet
--
let barPoped = 
  case init of State initF ->
    case (initF (push "foo")) of State fooPushedF ->
      case (fooPushedF (push "bar")) of State barPushedF ->
        barPushedF (pop)

fmap barToApple barPoped

-- final result: ["apple", "foo"] as the stack

```

---
<br />

<a name="fn-type-operator-built-in-syntax">1</a>: In real Haskell code, one cannot define a Functor using operator like `data (<>) a = (<>) a` without the [TypeOperators extension][1].

<a name="fn-io-embedded-effect">2</a>: For Functors like `IO`, although the reason is unknown, the affected `ReadWorld` is hidden from the user rather than appearing like `IO RealWorld a`. 

---

[1]: https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#type-operators
[2]: https://stackoverflow.com/questions/24103108/where-is-the-data-constructor-for-state
