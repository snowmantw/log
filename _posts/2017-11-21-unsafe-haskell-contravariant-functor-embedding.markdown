---
layout: post
title: "unsafeMemo: Contravariant Functor #2 - Embedding Functor"
date: 2017-11-18 11:47:00 +0900
categories: Haskell unsafeMemo
---

Different from Functor has only one type variable, an "embedding" Functor has two or more. Like the `s` in `State s a` means to manipulate a state during computation, or `r` in `(->) r a` for generating
functions that have the same input.

## Functor (State s)

<img style="border: 2px solid #bbb" src="https://docs.google.com/drawings/d/e/2PACX-1vSsiSa4A9yOu0XpnORj6zMtpuxRyZGQeAG9jnxsD3-qikKutT62Uvr_hpH1Yx0neU0_tuH8MvJH-pM-/pub?w=960&amp;h=720">

**In brief**:

1. For this definition it is easy to image that it provide user to interact with the state and the output in previous step. One thing to note is that although it seems the same with the `(->) r` Functor,
the real definition is actually `newtype State s a = State { runState :: s -> (s, a) }`. That means, the actual instance will be: `State (s -> (a, s))`. Compare to `Maybe a` or `(-> r) a`,
this is not easy to get the idea at the first look. The key is, user provides a state transformer to generate another state `s` and transformed result `a`.

2. A common example for tutorials is `State RandGen Int` that to generate a new `Int` from a random number generator. For each time it generates a random number, the generator need to be updated to prevent generating the same
number. Therefore, here we put the `RandGen` as the implicit `s` in State Functor after every transformation step.


---
<br />

## Functor (-> r)

<img style="border: 2px solid #bbb" src="https://docs.google.com/drawings/d/e/2PACX-1vSL5gFJq4Flm11a2ejcnSOOUxNJ3Rsa0XavkhD4xnMuQX8FbCePl7TT33Pei9wksqSM7yHSukE3wTlX/pub?w=960&amp;h=720">

**In brief**:

1. As a common case in some tutorials, `(->) r a` is similar to `Maybe a` or `IO a`,
the Functor has an "argument" `a` that can be transformed when `fmap` it, but the difference is that it has **an implicit parameter `r`** not directly accessible via the function to apply by `fmap`

2. We can have `(->) Event a` instance just like to have a `Maybe a`, but this time we can embed a fixed type variable `Event` in the Functor as one parameter. And how this parameter changes
during the computation is defined by the `fmap` of the Functor. Functor user apply an `(a->b)` cannot know and effect the parameter directly.

3. Although `(->)` looks like a special symbol that used so common in type signature, it is still an ordinary symbol that we can image to use in define a Functor<sup>[1](#fn-type-operator-built-in-syntax)</sup>, just like `Maybe` or `[]`.
The tricky part is we can "curry" a fixed type parameter when define and instantiate the Functor, like in this example the `r` in type class definition is instantiated to `Event`. Imaging it is `(-> r) a`
could prevent getting confused like the original `(->) r a` form that looks like there are two variables will be transformed for the user.

4. Since how to interact with the embedded parameter `Event` in this example is defined by the `fmap`, what the user can control is how to transform the argument of `(-> Event)` Functor. For example, if there is a Functor in type of
`(-> Event) Bool`, via applying a `(Bool->String)`, we should get a `(-> Event) String`, just like from `Maybe Bool` to `Maybe String` via applying the same function. 

5. For the practical usage, we can get a "function generator" that user only needs to provide a "transformer" for the output, and the input will always fixed to `Event`. These generated functions may be used in a specific usage like as
event stream handlers, and user don't need to take care about how to make the stream, or how to get the event. What user needs to do is to transform the possible output of the handler to a desired type.


### Explanation

The embedding Functors like `(->) r` is useful when the computation is not only about the argument transformation, but including to have some relation<sup>[2](#fn-io-embedded-effect)</sup> with the embedded type.
For example, `State s a` means the transformation is not just to `a` but also on `s`, while `(->) r` here means to always have the `r` as the input of the generated function.



---
<br />

<a name="fn-type-operator-built-in-syntax">1</a>: In real Haskell code, one cannot define a Functor using operator like `data (<>) a = (<>) a` without the [TypeOperators extension][1].

<a name="fn-io-embedded-effect">2</a>: Not a real principle; Like `IO a` has no such embedded type in the definition, but in fact it is just like `State RealWorld a`. I don't have answer for this now, but people always said `IO` is considered as a mistake for Haskell and invented Eff Monad (Functor) after that 

---

[1]: https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#type-operators
