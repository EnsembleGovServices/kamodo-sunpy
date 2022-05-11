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


Kamodo uses the [plotly graphing library](https://plotly.com/python/) to

* generate figures in-line for jupyter notebooks
* produce publication-ready graphics
* drive web applications via [plotly-dash](https://dash.plotly.com/installation)

We'll provide a brief overview of how plotly works before diving into Kamodo's use


## Plotly


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
fig['data'] # a list of graph objects
```

```python
fig['layout'] # determines axis layout, titles, etc
```

## Kamodo plotting


Normally, you would feed arrays into plotly's graph objects, which has a bit of a learning curve. Kamodo largely avoids this by doing most of the heavy lifting for you!

Kamodo automatically generates plotly figures from registered functions. This is accomplished through function inspection. Here is a simple example.

```python
import numpy as np

from kamodo import Kamodo, kamodofy
```

```python
k = Kamodo(f='x^2-x-1')

fig = k.plot(f={'x':np.linspace(-.618, 1.618, 330)}) # recall zeros are at values of the golden ratio
fig
```

To produce the above interactive plot, kamodo did the following:

1. evaluated $f(x)$ using the dictionary of `{argument: values}`
1. determined the input argument shape and output shape of the function
1. found a corresponding `plot_type` and function for these shapes (`kamodo.plotting.line_plot`)
1. passed the function results and arguments to `line_plot`
1. `line_plot` constructs a `go.Scatter` object and appropriate `layout`, including title
1. returned a plotly [figure object](https://plotly.com/python/figure-structure/)


Customization of the plot can be done through modifying the figure object with plotly keywords:

```python
fig.update_layout(title='hello')
```

```python
fig.update_traces(fill='tozeroy', fillcolor='white')
```

**kamodo plot types**


For step 3) above, kamodo used a mapping between function shapes and available plotting functions

```python
from kamodo.plotting import plot_types # a pandas dataframe storing registered plot types
plot_types
```

</details>


Here we can see a `1d-line` plot type for functions for 1-dimensional functions, where the input shape tuple `(N)` matches the output shape tuple `(N)`


This approach allows us to provide many plot types that fit a variety of situations.


**Contour plots**

```python
from kamodo import Kamodo
@kamodofy(units = 'cm^2')
def f_NM(x_N = np.linspace(0, 8*np.pi,100), y_M = np.linspace(0, 5, 90)):
    x, y = np.meshgrid(x_N, y_M, indexing = 'xy')
    return np.sin(x)*y

k = Kamodo(f_NM = f_NM)
k
```

Kamodo utilizes function defaults to generate quick-look graphics:

```python
fig = k.plot('f_NM')
fig
```

**Vector fields**

```python
x = np.linspace(-np.pi, np.pi, 25)
y = np.linspace(-np.pi, np.pi, 30)
xx, yy = np.meshgrid(x,y)
points = np.array(list(zip(xx.ravel(), yy.ravel())))

def fvec_Ncomma2(rvec_Ncomma2 = points):
    ux = np.sin(rvec_Ncomma2[:,0])
    uy = np.cos(rvec_Ncomma2[:,1])
    return np.vstack((ux,uy)).T

k = Kamodo(fvec_Ncomma2 = fvec_Ncomma2)
k
```

```python
k.plot('fvec_Ncomma2')
```

**3d vector field**

```python
x, y, z = np.meshgrid(np.linspace(-2,2,4),
                      np.linspace(-3,3,6),
                      np.linspace(-5,5,10))
points = np.array(list(zip(x.ravel(), y.ravel(), z.ravel())))
def fvec_Ncomma3(rvec_Ncomma3 = points):
    return rvec_Ncomma3

k = Kamodo(fvec_Ncomma3 = fvec_Ncomma3)
k
```

```python
k.plot('fvec_Ncomma3')
```

More examples are given in the [Visualization](https://ensemblegovservices.github.io/kamodo-core/notebooks/Visualization/) section of the documentation, including:
