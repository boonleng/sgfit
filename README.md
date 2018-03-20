SGFIT
===

An alternate implementation of Gaussian fitting. This method uses a complex-plain representation of the spectrum samples to find the mean, which accounts for the aliasing components of the Gaussian main lobe. The width and the amplitude are then derived by using the shifted Gaussian samples around the mean. The following example illustrates a case when a conventional Gaussian fitting can be applied successfully. Under this condition, there is no clear advantage of using the SGFIT method.

![Example of Guassian Fitting](blob/fig1.png)

On the other hand, when the main lobe of the spectrum spans across the aliasing limits, conventional Gaussian fitting methods would not be able to handle the situation since it no longer fits the assumptions of the model. Under this condition, the conventional method would fail but SGFIT would succeed.

![Example of GSFIT](blob/fig2.png)
