---
jupyter:
  jupytext:
    formats: ipynb,md
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

# Kamodo Models

We saw how to turn raw data into functions. While this is a straight-forward process, we do not want the end user of a scientific resource to do this. Instead, we wish to provide "Kamodofied" scientific resources, which collect pre-package kamodofied data into a Kamodo subclass.

This tutorial focuses on building such a Kamodofied model from scratch. To see the full implementation, skip down to the [Final-Implementation](#Final-Implementation).


## Kamodofication requirements

To Kamodofy models and data representing physical quantities, we need to define a set of functions representing the interpolation of each physical variable having the following properties:

* A function name and arguments that follows kamodo's [Syntax](../Syntax/) conventions 
* Default arrays for input arguments
* A meta attribute containing:
    * 'units' - physical units of the values returned by the function
    * 'citation' - How the model or data source should be cited
    * 'equation' - LaTeX representation of this model/data source (if available)
    * 'hidden_args' - A list of function arguments that should not be rendered
* A data attribute - The array holding the variable (if available)
* Any docstrings that provide further context


## Model Reader Tutorial

Model Readers load data from disk (or server) and provide methods for interpolation. We require that for each variable of interest, the model reader should provide at least one interpolation method that satisfies all of the above requirements. Each model reader will:

1. Open/close files
2. Manage state variables
3. Initialize interpolators
4. Kamodofy interpolators
5. Register functions


### Minimal Example: one variable

```python
from kamodo import Kamodo, kamodofy, gridify
from scipy.interpolate import RegularGridInterpolator
import numpy as np
import plotly.io as pio
```

```python
class MyModel(Kamodo): 
    def __init__(self, filename, **kwargs):
        # mock any necessary I/O
        print('opening {}'.format(filename))
        self.filename = filename
        self.missing_value = np.NAN
        
        # store any data needed for interpolation
        self.x = np.linspace(1, 4, 11)
        self.y = np.linspace(4, 7, 22)
        self.z = np.linspace(7, 9, 33) 
        
        xx, yy, zz = np.meshgrid(self.x, self.y, self.z, indexing='ij', sparse=True)
        density_data = 2 * xx**3 + 3 * yy**2 - zz
        
        self.interpolator = RegularGridInterpolator((self.x, self.y, self.z), density_data, 
                                                    bounds_error = False,
                                                   fill_value = self.missing_value)


        
        # Prepare model for function registration for the input argument
        super(MyModel, self).__init__(**kwargs) 
        
        # Wrap the interpolator with a nicer function signature
        @kamodofy(units = 'kg*m**-3')
        def interpolator(xvec):
            return self.interpolator(xvec)
        
        self['rho'] = interpolator


model = MyModel('myfile.dat')
model
```

we can call the registered function with multiple values, getting `nan` if out of bounds:

```python
model.rho([[2,5,8],
           [0,0,0]])
```

However, the registered function has no default parameters, so an error will be raised if we do not provide an argument.

```python
try:
    model.rho()
except TypeError as m:
    print(m)
```

At this point, the end-user of the model cannot generate quick-look graphics:

```python
try:
    model.plot('rho')
except TypeError as m:
    print(m)
```

In order to generate any plots, the user must already know where they can place resolution. For example, they could inspect some of the attributes of the model and guess the size of the domain, then choose points from that space.

```python
xx,yy,zz = np.meshgrid(model.x, model.y, model.z)
points = np.column_stack([xx.ravel(),yy.ravel(),zz.ravel()])
randints = np.random.randint(0,len(points), 1000)
```

```python
fig = model.plot(rho = dict(xvec = points[randints] ))
fig
```

```python
# pio.write_image(fig, 'images/kamodofied1.svg')
```

![kamodofied1](images/kamodofied1.svg)


Hopefully, the user doesn't choose points where the solution may be invalid. Next, we'll modify the original function to provide a griddable variable with default parameters.


## Including defaults

The above example produced a kamodofied model with one variable, but we are unable to produce quick-look graphics, which required the user to inspect the model to guess where interpolation may be valid. Here we show how to include defaults so the user doesn't have to guess.

```python
class MyModel(Kamodo): 
    def __init__(self, filename, **kwargs):
        # perform any necessary I/O
        print('opening {}'.format(filename))
        self.filename = filename
        self.missing_value = np.NAN
        
        # store any data needed for interpolation
        self.x = np.linspace(1, 4, 11)
        self.y = np.linspace(4, 7, 22)
        self.z = np.linspace(7, 9, 33) 
        
        xx, yy, zz = np.meshgrid(self.x, self.y, self.z, indexing='ij', sparse=True)
        density_data = 2 * xx**3 + 3 * yy**2 - zz
        
        self.interpolator = RegularGridInterpolator((self.x, self.y, self.z), density_data, 
                                                    bounds_error = False,
                                                   fill_value = self.missing_value)


        
        # Prepare model for function registration for the input argument
        super(MyModel, self).__init__(**kwargs) 
        
        # Wrap the interpolator with a nicer function signature
        @kamodofy(units = 'kg/m**3')
        @gridify(x = self.x, y = self.y, z = self.z) # <--- The only change to the model
        def interpolator(xvec):
            return self.interpolator(xvec)
        
        self['rho'] = interpolator
        

model = MyModel('myfile.dat')
model
```

By adding the `@gridify` line, we have modified the original function to be one that generates gridded data. Moreover, the variable now has default parameters.

```python
model.rho().shape
```

We can now specify one or more arguments to get a plane mapping of the solution.

```python
model.rho(z = 8).shape
```

But how do we know to choose the plane `z=8` for a valid solution? We can use kamodo's function inspection to get the default ranges for each parameter.

```python
from kamodo import get_defaults
```

```python
get_defaults(model.rho)['z'].mean()
```

## Final Implementation

In the final implementation of our model reader, we include multiple variables with different function signatures. Here, the gridded solutions have suffixes `_ijk` to emphasize their structure. This allows more flexibility for the end user.

```python
class MyModel(Kamodo): 
    def __init__(self, filename, gridify_model=True, **kwargs):
        # perform any necessary I/O
        print('opening {}'.format(filename))
        self.filename = filename
        self.missing_value = np.NAN
        self.gridify_model = gridify_model
        
        # store any data needed for interpolation
        self.x = np.linspace(1, 4, 11)
        self.y = np.linspace(4, 7, 22)
        self.z = np.linspace(7, 9, 33)        
        xx, yy, zz = np.meshgrid(self.x, self.y, self.z, indexing='ij', sparse=True)
        density_data = 2 * xx**3 + 3 * yy**2 - zz
        pressure_data = xx**2 + yy**2 + zz**2
        
        
        self.variables = dict(rho = dict(units = 'kg/m**3', data = density_data),
                              P = dict(units = 'nPa', data = pressure_data))

        # Prepare model for function registration
        super(MyModel, self).__init__(**kwargs) 
        
        for varname in self.variables:
            units = self.variables[varname]['units']
            self.register_variable(varname, units)
            
    def register_variable(self, varname, units):
        interpolator = self.get_grid_interpolator(varname)
        
        # store the interpolator
        self.variables[varname]['interpolator'] = interpolator

        def interpolate(xvec):  
            return self.variables[varname]['interpolator'](xvec)

        # update docstring for this variable
        interpolate.__doc__ = "A function that returns {} in [{}].".format(varname,units)

        self[varname] = kamodofy(interpolate, 
                           units = units, 
                           citation = "Pembroke et al 2019",
                          data = None)
        
        if self.gridify_model:
            print(f'registering {varname} in gridified form')
            self[varname + '_ijk'] = kamodofy(gridify(self[varname], 
                                                      x_i = self.x, 
                                                      y_j = self.y, 
                                                      z_k = self.z, squeeze=False),
                                units = units,
                                citation = "Pembroke et al 2019",
                                data = self.variables[varname]['data'])
        
            
    def get_grid_interpolator(self, varname):
        """create a regulard grid interpolator for this variable"""
        data =  self.variables[varname]['data']

        interpolator = RegularGridInterpolator((self.x, self.y, self.z), data, 
                                                bounds_error = False,
                                               fill_value = self.missing_value)
        return interpolator
            

model = MyModel('myfile.dat', gridify_model=True)
model
```

```python
model.rho((2,5,8))
```

```python
model.P((2,5,8))
```

```python
model.detail()
```

Notice we have made the gridifed functions optional, in case the user does not require them. Such design choices are left up to whoever authors the Kamodofied model. Some things to consider when designing your Kamodo models:

1. What is your end user most likely to need?
1. What are the typical names/units used in the literature for your domain?
1. Is this resource part of some other pipeline?
1. Are there type requirements you need to support?
1. If scientific notebooks exist for this dataset, start from there.



## Combined models


We could also register the model's interpolating method as part of some other Kamodo object, such as another kamodofied model reader or data source:

```python
from kamodo import Kamodo
kamodo = Kamodo(rho = model.rho)
kamodo
```

We can now compose our density function with expressions defined by other models:

```python
kamodo['vol[m^3]'] = '4/3 * pi * (xvec)**(3/2)'
kamodo
```

```python
kamodo['mass'] = 'rho*vol'
kamodo
```

```python
kamodo.detail()
```

The following lines will save the image to your working directory.

!!! note
    Saving images requires `plotly-orca-1.2.1`, available through conda: ```conda install -c plotly plotly-orca```

```python
model.rho_ijk().shape
```

```python
import plotly.io as pio
fig = model.plot(rho_ijk = dict(z_k = model.z.mean()))
fig
```

```python
from plotly.offline import iplot, init_notebook_mode, plot
```

```python
init_notebook_mode(connected = True)
```

```python
fig = model.plot(rho_ijk =  dict(z_k = [model.z.mean()]))
```

```python
pio.write_image(fig, 'kamodofied_model_1.svg', validate = False)
```

We use markdown to embed the image into the notebook.
![Kamodofied Density](kamodofied_model_1.svg?5)


Alternative ways to graph:

```python
## uncomment to open interactive plot in the notebook
# from plotly.offline import init_notebook_mode, iplot
# init_notebook_mode(connected = True)
# iplot(kamodo.plot(rho = dict(x = model.x.mean()))) 
```

```python
# # uncomment to open interactive plot in separate tab
# from plotly.offline import plot
# plot(kamodo.plot(rho = dict(z = 8))) 
```
