% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/out_chain.management.R
\name{combine.chains}
\alias{combine.chains}
\title{Combine chains in a fitted correlated rates Brownian Motion model}
\usage{
combine.chains(fit, simplify = T)
}
\arguments{
\item{fit}{An object of class "\code{corateBM_fit}", the output of a call to \code{fit.corateBM}.}

\item{simplify}{TRUE or FALSE value: should the resulting elements of \code{fit} have dimensions of length
1 collapsed and stored as attributes?}
}
\value{
an object of class "\code{corateBM_fit}". All previously-existing elements in \code{fit} will be
included.
}
\description{
This function combines all chains from the output of the function \code{fit.corateBM} in sequential order.
}
\details{
By sequential, I mean that the chains beginning of the second chain will follow the end of the
first chain, and so on. No permutation business is attempted. It is obviously unwise to run this function
with a \code{corateBM_fit} including chains that have not yet reached a stationary distribution or include
obvious burn-in/warmup iterations.

The resulting chain name will simply be all the previous chain names separated by commas (e.g.,
"chain 1, chain 2, chain 3, ...).

Any iterations included in the sampler.params element but not in the chains element are
automatically excluded. Otherwise, issues would result from other functions which assuming any
difference between the number of iterations in sampler.params and chains are due to iterations missing from
the beginning of chains (i.e., burn-in/warmup). Any warmup iterations remaining in the chains element,
however, will be kept.

After combining chains, the resulting composite 'markov chain' no longer corresponds to any one set of
initialization values. As such, the 'inits' diagnostic from the param.diags element is set to NA.
}
\seealso{
Other chain management: 
\code{\link{exclude.warmup}()},
\code{\link{select.chains}()},
\code{\link{thin.chains}()}
}
\concept{chain management}
