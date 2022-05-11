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

## Functions

Functions may be represented by many implementations/expressions (think right-hand-side)

### Closed form expressions (formulas)


Let's start with a simple latex expression we wish to functionalize.

$$ f(x) = x^2-x-1 $$


Kamodo offers some simple tools to turn the above right-hand-side expression into python functions that can operate on numerical data. This is accomplished with Kamodo's underlying [sympy](https://www.sympy.org/en/index.html) library.

```python
from kamodo import lambdify, parse_expr
```

First parse the string into a sympy expression

```python
expr = parse_expr('x^2-x-1') # convert latex into sympy expression
expr # will render as latex in jupyter
```

Alternatively, we could have parsed a python expression:

```python
expr = parse_expr('x**2-x-1')
expr
```

Expressions are the primary tool used by Kamodo to inspect and manpulation user-defined expressions. Here are some useful things one can do with expressions.


**substitution**

```python
expr.subs(dict(x='y'))
```

```python
expr.subs(dict(x='y-1'))
```

**symbol extraction**

```python
expr.free_symbols
```

**solutions**

```python
expr # solve for f(x) = 0
```

```python
from sympy import solve, symbols

zeros =  solve(expr, symbols('x')) 
zeros[0]
```

```python
zeros[1]
```

**numerical evaluation**

```python
zeros[0].evalf()
```

```python
zeros[1].evalf()
```

**type repr**

```python
from sympy import srepr

srepr(expr) # Expressions are composed of algebraic types
```

```python
expr
```

Sympy has [many other tools](https://docs.sympy.org/latest/tutorial/basic_operations.html) for manipulating such expressions. They are worth taking a look at, especially if you wish to [contribute to Kamodo](https://github.com/EnsembleGovServices/kamodo-core/blob/master/CONTRIBUTING.md)!

For our purposes, we are mainly interested in converting such preparing such expressions for numerical evaluation.


### Lambdified expressions


With variables identified, we can convert this expression into a python function that operates on numerical types

```python
f = lambdify(expr.free_symbols, expr)
f
```

```python
help(f)
```

Let's test this for accuracy

```python
f(3)
```

```python
assert f(3) == (3**2)-3-1
```

The generated function is optimized to work on arrays

```python
import numpy as np

f(np.linspace(-5,5,1000000)).shape # do a timing test here
```

!!! note
    Installing the [numexpr](https://github.com/pydata/numexpr) library makes this even faster!
