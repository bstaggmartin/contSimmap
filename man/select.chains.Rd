% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/out_chain.management.R
\name{select.chains}
\alias{select.chains}
\title{Select chains in a fitted correlated rates Brownian Motion model}
\usage{
select.chains(fit, chains, simplify = T)
}
\arguments{
\item{fit}{An object of class "\code{corateBM_fit}", the output of a call to \code{fit.corateBM}.}

\item{chains}{A character or numeric vector. If of class character, the given text is matched to names of
the available chains in \code{fit}. If of class numeric, the function assumes \code{chains} refers to the
name "chain \code{chains}".}

\item{simplify}{TRUE or FALSE value: should the resulting elements of \code{fit} have dimensions of length
1 collapsed and stored as attributes?}
}
\value{
an object of class "\code{corateBM_fit}". All previously-existing elements in \code{fit} will be
included.
}
\description{
This function extracts specific chains from the output of the function \code{fit.corateBM}.
}
\seealso{
Other chain management: 
\code{\link{combine.chains}()},
\code{\link{exclude.warmup}()},
\code{\link{thin.chains}()}
}
\concept{chain management}
