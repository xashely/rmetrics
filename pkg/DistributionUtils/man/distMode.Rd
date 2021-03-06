\name{distMode}
\alias{distMode}

\title{Mode of a Unimodal Distribution}
\description{
  Function to calculate the mode of a unimodal distribution which is
  specified by the root of the density function name and the
  corresponding parameters.
}
\usage{
distMode(densFn, param = NULL, ...)
}
\arguments{
  \item{densFn}{Character. The name of the density function for which
    the mode is required.}
  \item{param}{Numeric. A vector giving the parameter values for the
    distribution specified by \code{densFn}. If no \code{param} values
    are specified, then the default parameter values of each
    distribution are used instead.}
  \item{\dots}{Passes arguments to \code{\link{optimize}}. In
    particular, the parameters of the distribution.}
}

\details{
  The name of the unimodal density function must be supplied as the
  characters of the root for that density (e.g. \code{norm},
  \code{ghyp}). The particular unimodal distribution being considered is
  specified by the value of the argument \code{param}, or for base R
  distributions by specification in the \dots arguments.
}
\value{
  The mode is found by a numerical optimization using
  \code{\link{optimize}}.
}

\author{
  David Scott \email{d.scott@auckland.ac.nz},
  Joyce Li \email{xli053@aucklanduni.ac.nz}}

\seealso{
  \code{\link{distStepSize}}, \code{\link{qDist}}.
}

\examples{
normRange <- distCalcRange("norm", tol = 10^(-7), mean = 4, sd = 1)
curve(dnorm(x, mean = 4, sd = 1), normRange[1], normRange[2])
abline(v = distMode("norm", mean = 4, sd = 1), col = "blue")
}
\keyword{distribution}
\keyword{univar}

