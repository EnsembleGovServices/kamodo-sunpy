---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.13.8
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

## SkyKamodo class


Here is how you would normally work with SkyCoord objects

```python
import numpy as np
lon = np.linspace(0, 5, 5)
lat = np.linspace(0, 5, 7)

llon, llat = np.meshgrid(lon, lat)

llon.shape, llat.shape
```

```python
from astropy.coordinates import SkyCoord
import sunpy.coordinates # needed to find sunpy coordinate frames
```

```python
hpc = SkyCoord(llon, llat,
               unit='arcsec',
               obstime="2020/12/15T00:00:00",
               observer="earth",
               frame="helioprojective")

hgs = hpc.transform_to("heliographic_stonyhurst")
xvals = hgs.cartesian.x.value
yvals = hgs.cartesian.y.value
zvals = hgs.cartesian.z.value
points = np.array([xvals, yvals, zvals])
```

```python
points.shape
```

Here is how you would do this using the new `SkyKamodo` interface

```python
from sunpy_kamodo.transforms import SkyKamodo

sky = SkyKamodo(to_frame='HeliographicStonyhurst', from_frame='Helioprojective')
```

```python
sky
```

The registered cartesian vector function represents the conversion from $HGS$ to $HPC$

```python
points_ = sky.xvec_HGS__HPC(llon, llat, '2020/12/15T00:00:00') 
```

```python
assert (points_ == points).all() # check that the results match
```

```python
help(sky.xvec_HGS__HPC)
```

The SkyKamodo class can be used to register multiple coordinate transformations at once.


```python
from sunpy_kamodo.transforms import SkyKamodo
```

```python
sky = SkyKamodo(from_frame=['HPC', 'HGS'], to_frame=['HGS', 'HGC'])
```

Here we registered 3 permutations of HGS, HGC, and HPC:
* HPC->HGS
* HPC->HGC
* HGS->HGC

A fourth one (HGS->HGS) was ignored

```python
sky
```

```python
sky.detail()
```

## KamodoMap

```python
from sunpy_kamodo.transforms import SunMap
```

```python
# import matplotlib.pyplot as plt

from sunpy.data.sample import AIA_171_IMAGE

# aiamap = sunpy.map.Map(AIA_171_IMAGE)
# aiamap
```

```python
AIA_171_IMAGE
```

```python
sunmap = SunMap(AIA_171_IMAGE, '')
sunmap
```

```python
sunmap['i_px_log'] = 'ln(i_px)' # register log of image function
```

```python
import numpy as np
```

```python
alpha = np.linspace(-500, 0, 200)
delta = np.linspace(0, 500, 200)

fig = sunmap.plot(i_px_log = dict(alpha=alpha,
                        delta=delta))

fig.update_layout(height=800, width=800)
```

```python

```
