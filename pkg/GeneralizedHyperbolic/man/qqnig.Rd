\name{nigPlots}
\alias{qqnig}
\alias{ppnig}

\title{Normal inverse Gaussian Quantile-Quantile and Percent-Percent Plots}

\description{
  \code{qqnig} produces a normal inverse Gaussian Q-Q plot of the values in
	\code{y}.

  \code{ppnig} produces a normal inverse Gaussian P-P (percent-percent) or
  probability plot of the values in \code{y}.

  Graphical parameters may be given as arguments to \code{qqnig},
  and \code{ppnig}.
}
\usage{
qqnig(y, mu = 0, delta = 1, alpha = 1, beta = 0,
         param = c(mu, delta, alpha, beta),
         main = "Normal inverse Gaussian Q-Q Plot",
         xlab = "Theoretical Quantiles",
         ylab = "Sample Quantiles",
         plot.it = TRUE, line = TRUE, \dots)

ppnig(y, mu = 0, delta = 1, alpha = 1, beta = 0,
         param = c(mu, delta, alpha, beta),
         main = "Normal inverse Gaussian P-P Plot",
         xlab = "Uniform Quantiles",
         ylab = "Probability-integral-transformed Data",
         plot.it = TRUE, line = TRUE, \dots)
}

\arguments{
  \item{y}{The data sample.}
  \item{mu}{\eqn{\mu}{mu} is the location parameter. By default this is
    set to 0.}
  \item{delta}{\eqn{\delta}{delta} is the scale parameter of the distribution.
    A default value of 1 has been set.}
  \item{alpha}{\eqn{\alpha}{alpha} is the tail parameter, with a default value of 1.}
  \item{beta}{\eqn{\beta}{beta} is the skewness parameter, by default this is 0.}
  \item{param}{Parameters of the normal inverse Gaussian distribution.}
  \item{xlab, ylab, main}{Plot labels.}
  \item{plot.it}{Logical. Should the result be plotted?}
  \item{line}{Add line through origin with unit slope.}
  \item{\dots}{Further graphical parameters.}
}

\value{
  For \code{qqnig} and \code{ppnig}, a list with components:
  \item{x}{The x coordinates of the points that are to be plotted.}
  \item{y}{The y coordinates of the points that are to be plotted.}
}
\references{
  Wilk, M. B. and Gnanadesikan, R. (1968)
  Probability plotting methods for the analysis of data.
  \emph{Biometrika}.
  \bold{55}, 1--17.
}

\seealso{
  \code{\link{ppoints}}, \code{\link{dnig}}, \code{\link{nigFit}}
}


\examples{
par(mfrow = c(1, 2))
param <- c(2, 2, 2, 1.5)
y <- rnig(200, param = param)
qqnig(y, param = param, line = FALSE)
abline(0, 1, col = 2)
ppnig(y, param = param)
}
\keyword{hplot}
\keyword{distribution}
