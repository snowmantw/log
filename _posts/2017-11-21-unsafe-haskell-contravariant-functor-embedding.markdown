---
layout: post
title: "unsafeMemo: Contravariant Functor #2 - Embedding Functor"
date: 2017-11-18 11:47:00 +0900
categories: Haskell unsafeMemo
---

Different from Functor has only one type variable, an "embedding" Functor has two or more. Like the `r` in `(->) r a` for generating
functions that have the same input, or `s` in `State s a` means to manipulate a state during computation.

(And `State s a` is actually very interesting if we revise it strictly within the scope of a Functor, not Monad)

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


### In Detail

The embedding Functors like `(->) r` is useful when the computation is not only about the argument transformation, but including to have some relation<sup>[2](#fn-io-embedded-effect)</sup> with the embedded type.
For example, `State s a` means the transformation is not just to `a` but also on `s`, while `(->) r` here means to always have the `r` as the input of the generated function.



---
<br />

<a name="fn-type-operator-built-in-syntax">1</a>: In real Haskell code, one cannot define a Functor using operator like `data (<>) a = (<>) a` without the [TypeOperators extension][1].

<a name="fn-io-embedded-effect">2</a>: For Functors like `IO`, although the reason is unknown, the affected `ReadWorld` is hidden from the user rather than appearing like `IO RealWorld a`. 

---

[1]: https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#type-operators
[2]: https://stackoverflow.com/questions/24103108/where-is-the-data-constructor-for-state
