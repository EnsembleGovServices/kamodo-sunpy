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

## Visualization


## Plotly


Kamodo uses the [plotly graphing library](https://plotly.com/python/) to

* generate figures in-line for jupyter notebooks
* produce publication-ready graphics
* drive web applications via [plotly-dash](https://dash.plotly.com/installation)


The plotly frontend library is [built on react-js](https://plotly.com/javascript/react/) and embeds [D3](https://d3js.org/) charts in the browser. Plotly supports backends targeting Python, R, Julia, Matlab, Javascript, ggplot2, F#, etc.


**Figures**


Plotly figures are composed of groups of traces and a layout object.

```python
import plotly.graph_objs as go
```

Here is a simple plotly figure:

```python
fig = go.Figure(data=[go.Scatter(x=[0,1,2,3], y=[0,1,4,9])], # scatter object
               layout=dict(title='hello world'))
fig
```

Here we used a Scatter graph object to show a simple line plot. Plotly has [many other plot types](https://plotly.com/python-api-reference/plotly.graph_objects.html#graph-objects) which are worth exploring.


Plotly figures are basically dictionaries that are serialized and sent to the client browser for rendering.

```python
fig['data']
```

```python
fig['layout']
```

## Kamodo plotting


Most data science applications require the user to feed arrays into plotly's functions and therefore users have to learn the plotting library before they can use it. Kamodo largely avoids this, by doing most of the heavy lifting for you!

Kamodo automatically generates plotly figures from registered functions. This is accomplished through function inspection. Here is a simple example.

```python
import numpy as np

from kamodo import Kamodo, kamodofy
```

```python
k = Kamodo(f='x^2-x-1')
```

```python
k.plot(f={'x':np.linspace(-.618, 1.618, 330)}) # zeros are at the golden ratio
```

To produce the above interactive plot, kamodo did the following:

1. evaluated $f(x)$ using the keyword arguments passed to `plot`
1. determined the input argument shape and output shape of the function
1. found a corresponding `plot_type` and function for these shapes (`kamodo.plotting.line_plot`)
1. passed the function results and arguments to `line_plot`
1. line_plot constructs a go.Scatter object and appropriate layout, including title
1. returned a plotly [figure object](https://plotly.com/python/figure-structure/)


For step 3), kamodo uses a mapping between function shapes and available plotting functions

```python
from kamodo.plotting import plot_types # a pandas dataframe storing registered plot types

plot_types[plot_types['plot_type'] == '1d-line'] # 
```

Here we can see a `1d-line` plot type for functions for 1-dimensional functions, where the input shape tuple `(N)` matches the output shape tuple `(N)`


This approach allows us to provide many plot types that fit a variety of situations.

```python
plot_types
```

More examples are given below:

```python
s = np.linspace(0, 8*np.pi, 100)
x = 10*np.sin(s/8)
y = 10*np.sin(s)
z = s

@kamodofy(units = 'kg')
def f_N(x_N = x, y_N = y, z_N = z):
    return x_N**2+y_N**2+z_N**2

k = Kamodo(f_N = f_N)

k.verbose=True
kamodo.plot('f_N')
```

```python

```
