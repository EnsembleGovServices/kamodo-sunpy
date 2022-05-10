---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.11.5
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

## Kamodo class

The `Kamodo` class is a container used to register, manipulate, evaluate, and plot functions representing scientific resources.


### Function registration


Previously, we saw how sympy may be used to convert raw latex or python expressions into numerical functions. The Kamodo class handles this automatically at function registration time. 

```python
from kamodo import Kamodo
```

```python
k = Kamodo(f='x^2-x-1')
k
```

To access the above function, we can use "dot" notation:

```python
assert k.f(3) == 3**2 - 3 - 1
```

Again, such functions are compatible with numerical datatypes.

```python
import numpy as np
```

```python
k.f(np.linspace(-5,5,30000)).shape
```

We can also register functions with dictionary syntax. Each new function is appended to the list.

```python
k['g'] = 'x+y'
k
```

```python
k['h'] = 'x*y'
k
```

### Evaluation

For the most part, Kamodo is agnostic with respect to data types. Type validation is left up to function implementation. (The exception is kamodo's automated plotting, which we'll cover later.)

```python
k.f
```

```python
try:
    k.f('hey')
except TypeError as m:
    print(m)
```

In the above example, strings types throw an exception because `f` uses the `pow` function, which does not support strings.

```python
k.g
```

```python
k.g('hey... ', 'listen!')
```

Here, string types are ok, but only because the `add` operator can concatonates strings.

Similarly, multiplication happens to work between lists and integers.

```python
k.h
```

```python
k.h(5, ['wow'])
```

Even though this is quite flexible, you should **try to use numeric data types**, especially when units come into play (next lesson)


### Composition


The `Kamodo` class will compose functions when previously defined function symbols are detected.

```python
k = Kamodo(f='x^2-x-1')
k
```

```python
k['g'] = 'y^2'
k
```

```python
k['h'] = 'g(f)' # compose g on f
k
```

```python
assert k.h(3) == (3**2-3-1)**2
```

Two important things to note:

1. Kamodo detected a registered function `f` appearing in the right-hand-side of `h`
2. Kamodo determined that `h` must be a function of `x` through the composition `g(f(x))`.
