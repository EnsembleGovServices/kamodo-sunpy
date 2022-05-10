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

### Functionalizing data

Kamodo makes it easy to represent raw data as functions, by making use of interpolation (or extrapolation).


Suppose we have some time series data we wish to functionalize. For the purposes of this example, we'll use a fake time sequence:

```python
import pandas as pd
import numpy as np
t_N = pd.date_range('Nov 9, 2018', 'Nov 20, 2018', freq = 'H')

dt_days = (t_N - t_N[0]).total_seconds()/(24*3600) # seconds
data =  1+np.sin(dt_days) + .1*np.random.random(len(dt_days))
```

```python
ser = pd.Series(data, index=t_N)
ser.head()
```

Next, we'll define a time interpolator.

```python
def rho(t=t_N):
    """Density as a function of time"""
    ser_ = ser.reindex(ser.index.union(t))
    ser_interpolated = ser_.interpolate(method='time', limit_area='inside')
    result = ser_interpolated.reindex(t)
    return result
```

!!! note
    The above interpolator assumes the input is a pandas time series. Again, this is the prerogative of the interpolator author and is not a kamodo requirement.


Now we can evaluate $\rho(t)$ for *any* time within the domain of the original data (return `NaN` otherwise).

```python
t0 = pd.Timestamp('2017-11-09 00:01:00')
t1 = pd.Timestamp('2018-11-09 00:33:00')
t2 = pd.Timestamp('2018-11-09 00:38:00')
t3 = pd.Timestamp('2022-11-01 00:01:00')

rho([t0, t1, t2, t3])
```

```python
t_N
```

Since we provided the original time index as the function default, calling $\rho(t)$ with no arguments will return the original data 

```python
rho()
```

Check that the function results match the raw data

```python
assert (rho().values == data).all()
```

By functionalizing the raw data, we've made it more flexible, allowing us to evaluate over new time domains without losing access to the underlying dataset.


### Kamodofy


We can attach additional metadata to the function to give the end user greater context.

```python
from kamodo import kamodofy

@kamodofy(units='kg/m^3', citation='Put a DOI here if available')
def rho(t=t_N):
    """Density as a function of time"""
    ser_ = ser.reindex(ser.index.union(t))
    ser_interpolated = ser_.interpolate(method='time', limit_area='inside')
    result = ser_interpolated.reindex(t)
    return result

rho # renders as latex due to rho._repr_latex_ method
```

We didn't specify the right-hand-side, so `@kamodofy` gave it the lambda symbol to represent an [anonymous function](https://en.wikipedia.org/wiki/Anonymous_function).


`@kamodofy` also attached `meta` and `data` attributes to the function.

```python
rho.meta
```

The above citation information also appears in the documentation:

```python
help(rho)
```

```python
rho.data # represents the raw data (rho called with no arguments)
```

!!! note
    We attached the above metadata without modifying/recasting the original datatypes.
