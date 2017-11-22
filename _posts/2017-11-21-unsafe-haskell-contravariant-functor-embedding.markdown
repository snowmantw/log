---
layout: post
title: "unsafeMemo: Contravariant Functor #2 - Embedding Functor"
date: 2017-11-18 11:47:00 +0900
categories: Haskell unsafeMemo
---

## "Embedding" Functor: (->) r

<img src="https://docs.google.com/drawings/d/e/2PACX-1vSL5gFJq4Flm11a2ejcnSOOUxNJ3Rsa0XavkhD4xnMuQX8FbCePl7TT33Pei9wksqSM7yHSukE3wTlX/pub?w=960&amp;h=720">

**In brief**:

1. Different from Functor has only one type variable, an "embedding" function has two or more. For usual cases in turtorial, `(->) r` is a very common example. Similar to `Maybe a` or `IO a`,
the Functor has an "argument" `a` that can be transformed when `fmap` it, but there is an implicit parameter `r` not direcrtly accessible via the function to apply by `fmap`

2. Assume that we treat `(->) Event a` as a Functor, just like `Maybe a`, but this time we can embed a fixed type variable `Event` in the Functor as one parameter. And how this parameter changes
during the computation is defined by the `fmap` of the Functor. Functor user apply an `(a->b)` cannot know and effect the parameter directly.

3. Although `(->)` looks like a special symbol that used so common in type signature, it is still an ordinary symbol that we can image to use in define a Functor<sup>[1](#fn-type-operator-built-in-syntax)</sup>, just like `Maybe` or `[]`.
The tricky part is we can "curry" a fixed type parameter when define and instantiate the Functor, like in this example the `r` in type class definition is instantiated to `Event`. So in the following example, to image it as `(-> Event) a`
should be easier to not get confused by the plain `(->) Event a`, or `(->) r a` that looks like there are two variables will be transformed for the user.

4. Since how to interact with the embedded parameter `Event` in this example is defined by the `fmap`, what the user can control is how to transform the argument of `(-> Event)` Functor. For example, if there is a Functor in type of
`(-> Event) Bool`, via applying a `(Bool->String)`, we should get a `(-> Event) String`, just like from `Maybe Bool` to `Maybe String` via applying the same function. 

5. For the pratical usage, we can get a "function generator" that user only needs to provide a "converter" for the output, and the input will always fixed to `Event`, while these generated functions may be used in a specific usage like as
event stream handlers, and user don't need to take care about how to make the stream, or how to get the event. What user needs to do is to convert the possible output of the handler to a desired type.

### Explanation

The first thing is why we need embedding Functors like `(->) r`, and when we use them in pratical code.

3. Maybe the most confused part of this Functor is `(->)`: at the beginning of learning Haskell, although it is mentioned that infixed operators are just ordinary prefix operator with syntax sugar,
the symbol infix `(->)` is so basic and common in type signature, to put it just as a name of Functor like `Maybe` or `[]` is difficult to image, not to mention 

The typeclass of Functor tagged as 1. in the diagram is:

```haskell 
class Functor f where
  fmap :: (a->b) -> f a -> f b
```

The point is, `f` could be any data type, like `Maybe`, `[]`, `IO`, or even `(,)`<sup>[3](#fn-functor-datatype)</sup> and `(->)`.
And since Functor is a typeclass, type variable in instance is available:


```haskell 
instance Functor ([]) where
  fmap = ...

instance Functor ((->) a) where
  fmap = ...
```

The later one, when using it, is actually **embedding** a variable of type `a` inside the Functor.
This makes it **different** from the "simple" Functors like `Maybe` or `IO`. Since in those Functors,
especially when using them in code, all variables are transparent to the function applied in `fmap`:


```haskell 
fmap isOdd [3,4,5]    -- isOdd will get its input from ([] a) while `a` is Int
fmap isOdd (Just 5)   -- isOdd will get its input from (Maybe a) while `a` is Int
fmap isOdd readInt    -- isOdd will get its input from (IO a) while `a` is Int
```

In this example, `isOdd` can handle the variable now go with Functor well, since these Functor will give the only one
variable to it, namely, the `Int` variable. Programmer can trace the code according the definition of `fmap` easily:

```haskell 
class Functor f where
  fmap :: (a->b) -> f a -> f b

fmap isOdd readInt
--
-- since `f a` is `readInt:: IO Int`, thus `f` is `IO` and  `a` is `Int`,
-- the `isOdd` to apply will get the `a` from `readInt`.
```

For the **"container"** Functors as 2. in the diagram, it is easy to image that the Functor is a container
and the `fmap` is to treat the contained variable to the applying function. Even for those **"context"** Functors like `IO` tagged as 3.,
a similar explanation:

> "Functor IO is to do variable transformation with the function in a specific context,
> so that the transformation can be isolated from other pure computation not in the context"

is not too difficult to image. Since where the input comes from and what's the output of the whole `fmap` is obvious.

However, in the case like Functor `(->) a)` as 4., there are some other things in the instantiating code:

```haskell 
class Functor f where
  fmap :: (a->b) -> f a -> f b

fmap isOdd round
--
-- what will be the "input" of `isOdd` from `round`,
-- without reading the implementation of fmap ??? 
--
```

Apparently it is necessary to have a new way to image how the things work here, and this is strongly coupled with the usage
of the Functor, namely it's "role" for programmer. Since without knowing the usage of the Functor, and how it get implemented and used in code,
even tracing the whole type definitions won't give programmers more insight of the context. This will be covered in the next unsafeMemo.

**Next: Embedding Functors**

---

## <a name="appendix"></a>Appendix: fmap in non-embedding Functor 

<img src="https://docs.google.com/drawings/d/e/2PACX-1vTrqsXUzPVtXA19S2HthlOXu-vSr-8nlCnDNcslBhz0plSUvSbExYcI4VQJdsfJj1wig4_akjGhW_w1/pub?w=960&amp;h=720">

**In brief**:

1. I would like to call the function with signature `(a->b)` in `fmap` a **"transformer"**, since its job
is to transform the input from Functor by `fmap`.
2. Color means the value is different, while sometime the type in text keep the same 
3. Although there is no "statement" in Haskell language, this sequence of transformation can be done in different way,
even without the help from Monad

---
<br />

<a name="fn-unsafe">1</a>: no guarantee for safety, correctness and not outdated

<a name="fn-stackoverflow-ref-1">2</a>: [https://stackoverflow.com/questions/38034077/what-is-a-contravariant-functor]()

<a name="fn-functor-datatype">3</a>: [https://hackage.haskell.org/package/base-4.8.1.0/docs/src/GHC.Base.html#line-625]()

<a name="fn-sidenote">4</a>:
**(Side note about diagrams and "unsafe" explanations)**

People usually admire the high abstraction among typeclasses like Functor or Monad, it is like:

```haskell 
[] a
Maybe a
IO a

-- they have the same pattern:

m a

-- so we can have the same abstract operators among all:

fmap :: (Functor f) => (a -> b) -> f a -> f b
>>= :: (Monad m) => m a -> (a -> b) -> m b

-- while using the operator, like `fmap`:

fmap isOdd [3,4,5,6] -- [True, False, True, False]
fmap isOdd (Just 3)  -- Just True
fmap isOdd readInt   -- IO (depends on the user input)
```

Usually the following description will be like:

> "Look! We can abstract List, IO and other structures as in the same abstraction, wonderful!"

However, the problem is when a programmer tries to study and use those abstract structures,
their usages are actually very different. And such difference are in fact important to who tries to understand the idea by reading type signatures.

For example, tutorials about Functors not in the simple shape above, usually will jump to the following Functors directly:

```haskell 
State s a
(->) a b
```

And after explanations similar to the simple ones like `Maybe a`, the example actually will be much more complicated than their simpler cousins:

```haskell 
-- 
-- explain that `random` will generate new random generator,
-- with some content about why to change random generator is necessary,
-- and of course how `State s` is supposed to work with that
--
let useRand = State random
fmap useRand (State RandGen) -- State RandGen' (random Int like 123)
```

Or for `(->) a b`:


```haskell 
--
-- try to explain that the scary `->` in type signature is actually a functor,
-- if it combine with the "input" `a`, and add more concepts that fmap for `(->) a` is
-- actually function composition `(.)`
--
fmap isOdd round = isOdd . round
```

I have found that to focus on these common parts of the abstraction and type signatures,
although they are the essential and very powerful concept in Haskell language,
are obstacles in the way toward understanding. Since type signatures are lack of context of how, why and when to use
these abstract structures, even reading through the whole symbol transformation in the signature and the actual examples,
those *reasons* are still hidden in the text of article.

Therefore, I decide to add some more diagrams and explanations not so official for the concepts and examples,
since it is easier to use diagram to describe like variable or type in different step of tracing the signature and code.

---
