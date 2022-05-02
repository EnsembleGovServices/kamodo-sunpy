



# Introduction to Kamodo

### PyHC Summer School / Jun 3 2022 / ESAC, Madrid, Spain
Asher Pembroke (DBA/Ensemble) w/Ensemble LTD in partnership with CCMC

Special Thanks: Laura Hayes



![what is kamodo](WhatIsKamodo/WhatIsKamodo.001.jpeg)


### What is a scientific resource?

Mirriam-Webster Definition of resource:

    1. a source of information or expertise


Scientific resources are 

* Observables on a well-defined domain of scientific interest
* Can be purely functional (coordinate systems, expressions)
* Often associated with scientific units of measure
* Intended for downstream users

Scientific resources **are not** the tools themselves:

* Specific file formats (e.g. hdf, cdf, netcdf)
* specific APIs
* Raw model output or observational data


### What are functions?

Kamodo registers functions, but what are they?

> In mathematics, a function from a set X to a set Y assigns to each element of X exactly one element of Y. The set X is called the domain of the function and the set Y is called the codomain of the function. - Wikipedia

* A function is uniquely represented by the set of all pairs (x, f (x)) (a.k.a. the [graph](https://en.wikipedia.org/wiki/Graph_of_a_function) of a function)
* Colloquially, **functions take inputs and return outputs**

Functions **are not** the tools themselves:
* Expressions: `f(x) = x**2+y**2+z**2`
* Code blocks: `lambda x: x**2 + y**2 + z**2`
* Variables: `rho` (the codomain) is not the same as `rho(x)` (the function)


### Why are functions so important?

Functions often describe the physical state of the systems we are investigating
* Fields (Electromagnetic, fluid, etc)
* Derived variables
* Coordinate transformations
* Images (pixel coordinates)

Functions may readily be used downstream:
* Evaluation
* Composition
* Graphing
* Pipelining


### What is a functional API?

A functional API's focuses on providing information primarily in the form of functions, rather than the underlying data or objects themselves
* low barrier to entry
* (mostly) self-describing
* almost no side effects
* ammenable to functional programing techniques

As opposed to
* data-oriented api (REST)
* fixed file format
* Object Oriented APIs
