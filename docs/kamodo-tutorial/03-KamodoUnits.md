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

## Kamodo Units

Kamodo identifies units at registration time via bracket notation.

```python
from kamodo import Kamodo
```

```python
k = Kamodo('f(x[cm])[kg/m^3]=x^2-x-1')
k
```

Another way to read the above:

> **When $x$ is given in $cm$, I promise to return $kg/m^3$**
>
> --  sincerely, $f(x)$


In Kamodo, **units are strictly associated with a function's metadata**. Units are not attached to a type (as in astropy, pint, etc). 


We can easily identify the units of `f` on the left-hand-side of the registered function. We can also access this information through `f`'s `meta` attribute.

```python
k.f.meta
```

This information also appears in the `detail` method of the kamodo object:

```python
k.detail()
```

## Evaluation

Since units are just metadata, evaluation is unaffected:

```python
assert k.f(3) == 3**2-3-1
```

The only difference is that we now know the output is `kg/m^3` as described by the function's metadata.


## Unit conversion

During composition, Kamodo inserts unit conversion factors into user-defined expressions. 

```python
k['g(x[m])[g/cm^3]'] = 'f'
k
```

Another way to read the expression for g:

> If you give me $x$ in `m`, I promise to return `g/cm^3`. To do this, I will need to multiply $x$ by `100` before calling $f$ (since $f$ requires `cm`). Finally, I'll divide the result by $1000$ to get from $kg/m^3$ to $g/cm^3$.
>
> --sincerely, g(x)


Since the conversion factors are clearly visible in the generated expressions, unit conversion is explicit. This makes it easy to compare our results with back-of-the-envelope calculations.

```python
help(k.g)
```

**How this works**


Under the hood, Kamodo makes use of Sympy's powerful unit system, by multiplying symbols by their unit and eliminating these pairings from the right-hand-side.


To manage all this book keeping, Kamodo objects contain a unit registry:

```python
k.unit_registry
```

## Example: gravitational acceleration

```python
# Note: is an open registration bug that prevents functions of three variables with units from working
# https://github.com/EnsembleGovServices/kamodo-core/issues/92
# G_c = 6.674E-11 # N*m^2/kg^2

k = Kamodo('g(M[kg],r[m])[m/s^2]=6.67E-11*M/r^2')
k.g
```

```python
k.g(5.972e24, 6371000.) # M_E[kg]=5.972e24, R_E[m]=6371000.
```
