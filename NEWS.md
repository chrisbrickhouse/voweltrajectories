# voweltrajectories 0.2.0
## Major changes
* Adds `dctprediction()` which returns the predicted values of a DCT model. See `?dctprediction` for more information.
* As noted in 0.1.0, the `matrix` parameter of `dcterror()` has been removed. To get predicted values us `dctprediction()`.
* The package is now licensed under the GNU General Public License v3 or later.

## Minor changes
* Hypothetical test data are included as "VowelA" and "VowelB" datasets. They can be used to test the functions or examine correct input data formats. Use `data("VowelA")` and `data("VowelB")` to include them.
* Unit tests have been added.

# voweltrajectories 0.1.0
Initial build with private distribution under the MIT license.