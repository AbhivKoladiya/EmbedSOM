% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{PlotGG}
\alias{PlotGG}
\title{Wrap PlotData result in ggplot object.}
\usage{
PlotGG(embed, fsom, ...)
}
\description{
This creates a ggplot2 object for plotting.
Use:
}
\details{
PlotGG(...) + geom_point()

Slight point style modification is recommended:

PlotGG(...) + geom_point(aes(color=yourColName), alpha=.3, size=.3)
}
\examples{

EmbedSOM::PlotGG(e, fs, cols=F) + geom_point(alpha=.5, size=.3, aes(color=Density))

EmbedSOM::PlotGG(e, fs, cols=8, names='CD5') + geom_point(alpha=.5, size=.3, aes(color=CD5))

plt <- EmbedSOM::PlotGG(e, fs, cols=c(10,11), names=c('CD4','CD8'), colorScale=F)
plt + geom_point(alpha=.5, size=.3, aes(color=CD4))
plt + geom_point(alpha=.5, size=.3, aes(color=CD8))

}
