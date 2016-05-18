# Admin

## Prerequisites
PostgreSQL 9.5.2 x64
PostGIS 2.2.1
Python 3.3 x64 (on system PATH)
 * install pip 
   1) download https://bootstrap.pypa.io/get-pip.py
   2) python get-pip.py
 * install xmltodict
   Run (in Python directory): Scripts/pip install xmltodict
 
## Troubleshooting

#### If unable to install PostGIS 2.2.1 bundle on a clean PostgreSQL 9.5.2
install ERROR: could not load library "../9.5/lib/rtpostgis-2.2.dll" follow [364-PostGIS-2.2-Windows-users-hold-off-on-installing-latest-PostgreSQL-patch-release] (http://www.postgresonline.com/journal/archives/364-PostGIS-2.2-Windows-users-hold-off-on-installing-latest-PostgreSQL-patch-release.html).

#### If installing xmltodict raise an Exception:
```
  File "<PYTHON_DIR>\lib\mimetypes.py", line 256, in read_windows_registry
    with _winreg.OpenKey(hkcr, subkeyname) as subkey:
  TypeError: OpenKey() argument 2 must be str without null characters or None, not str
```
change catching exception on the line 265 from:
```
                except EnvironmentError:
```
to
```
                except Exception:
```
