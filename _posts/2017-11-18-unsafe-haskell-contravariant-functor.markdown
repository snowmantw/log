---
layout: post
title: "unsafeMemo: Contravariant Functor #1 - Functor"
date: 2017-11-18 11:47:00 +0900
categories: Haskell unsafeMemo
---

## Preface

Since I'm not an expert, sometimes to read Haskell articles and then turn those abstract ideas to mine is difficult.
This is even worse for me not a English or Mathematic native, so I decide to draw diagrams and adding "unsafe"<sup>[1](#fn-unsafe)</sup> explanation to those
ideas and diagrams. Apparently, I can only guarantee these explanations work for me, and maybe they are not 100% map back to the correct idea in Haskell or
math. However, I hope these diagrams eventually helps anyone like me, or there would be some patches after I post the articles.

## About this article

Recently I re-read some articles about Contravariant Functor. For people who try hard to get the idea of such abstract structure, fortunately there are
StackOverflow<sup>[2](#fn-stackoverflow-ref-1)</sup> and searching results give detailed references with
actual examples in code. However, I have the same feeling to them when I was reading articles about Functors: there should be some diagrams and extra
explanation for the type and value transformation, so that when a programmer is tracing type signatures and examples, the relations by steps may be
depicted more clearly, at least more clearly to me<sup>[4](#fn-sidenote)</sup> . Therefore, I made some diagrams and write text for them. As I said, these are **"unsafe"** memo,
I may misunderstand some concepts of Haskell, or some extra information are actually redundant, so there is no guarantee for the gain after reading.

## Functors by usage

Functors divided by different **"roles"** for different usages:

<img style="border: 2px solid #bbb" src="https://docs.google.com/drawings/d/e/2PACX-1vQV4UudBo7IxzZhjdKz58Ik25VM70MkdJ_OYcNiZgsgdtHLX8F7Gr28J56LbC3UZDpYTvo1OuucGACs/pub?w=842&amp;h=659">

**In brief**:

1. Functor definition is to have a type variable `a` and a `fmap` to apply a customised function to the value of `a`.
There is a diagram in [Appendix](#appendix) for `fmap` if it looks an unfamiliar concept. 
2. Some Functors are designed as a "container", like `[]` and `Maybe`. The `fmap` will apply the function to the value inside the container Functor
3. For Functors like `IO`, it is more like for applying transformation inside one specific context for isolation and specific purpose,
since there is no "container" anymore
4. The **"embedding"** Functors means they will have a embedded type variable that is not directly fed as a value to the applying function in `fmap`,
but the whole `fmap` is designed to have interaction with the embedded one

### Explanation

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

<a name="fn-unsafe">1</a>: No guarantee for safety, correctness and not outdated

<a name="fn-stackoverflow-ref-1">2</a>: [https://stackoverflow.com/questions/38034077/what-is-a-contravariant-functor](https://stackoverflow.com/questions/38034077/what-is-a-contravariant-functor)

<a name="fn-functor-datatype">3</a>: [https://hackage.haskell.org/package/base-4.8.1.0/docs/src/GHC.Base.html#line-625](https://hackage.haskell.org/package/base-4.8.1.0/docs/src/GHC.Base.html#line-625)

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
