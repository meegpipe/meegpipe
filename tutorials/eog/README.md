Regressing out ocular artifacts
===

This tutorial illustrates how `meegpipe` can be used to correct ocular 
artifacts using a classical technique: regressing out one or more reference
EOG signals from your EEG data. 

## Least squares regression

The easiest way of regression consists on using the whole EEG dataset to 
learn the regression filter weights. Despite its simplicity, this approach 
often produces excellent results. 


## Adaptive regression

One could regress out the EOG reference signals using an adaptive filter, 
such as a [Recursive Least Squares (RLS)][rls] filter. Such adaptive 
regression algorithms are able to handle, to certain degree, nonstationary
 data. However, most adaptive regression filters (especially RLS-based) 
easily become unstable and are rarely suitable for processing long-duration
EEG datasets. There are ways to overcome these stability problems at the 
expense of increasing the complexity of the algorithm, but at this point 
`meegpipe` does not implement any stable adaptive filter (but see [1]). 
Nevertheless, `meegpipe` does allow you to account for non-stationary data
 by performing simple least squares regression in sliding (possibly 
overlapping) windows. This approach does not have stability issues and, 
in practice, it removes ocular activity as effectively as stable versions 
of the RLS algorithm [2].  



[rls]: http://en.wikipedia.org/wiki/Recursive_least_squares_filter


## References

[1] _The Automatic Artifact Removal (AAR) plug-in for EEGLAB_. Available at:
http://germangh.com/aar

[2] Liavas and Regalia, _On the numerical stability and accuracy of the 
conventional recursive least squares algorithm_, IEEE Transactions on 
Signal Processing, 47 (1), 1999. DOI: [10.1109/78.738242](http://dx.doi.org/10.1109/78.738242)
