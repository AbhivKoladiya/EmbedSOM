# This file is part of EmbedSOM.
# 
# EmbedSOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# EmbedSOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with EmbedSOM. If not, see <https://www.gnu.org/licenses/>.

#' Process the cells with SOM into a nice embedding
#' 
#' @param fsom FlowSom object with a built SOM
#' @param data Data matrix with points that optionally overrides the one from `fsom$data`
#' @param map Map object in FlowSOM format, to optionally override `fsom$map`
#' @param n How many SOM neighbors to take seriously
#' @param k How many SOM neighbors to take into the whole computation
#' @param adjust How much non-local information to remove (parameter a)
#' @param importance Importance of dimensions that was used to train the SOM
#' @return matrix with 2-D coordinates of the embedded cels
#'
#' @useDynLib EmbedSOM, .registration = TRUE
#' @export

EmbedSOM <- function(fsom=NULL, n=NULL, k=NULL, adjust=NULL, data=NULL, map=NULL, importance=NULL) {
  #TODO validate the sizes of data, colsUsed and codes.

  if(is.null(map)) {
    if(is.null(fsom)) {
      stop("You need to supply a map.")
    } else map <- fsom$map
  }

  if(is.null(data)) {
    if(is.null(fsom)) {
      stop("You need to supply the data points.")
    } else data <- fsom$data
  }

  if(is.null(n) && is.null(k)) {
    k <- as.integer(2*sqrt(map$xdim*map$ydim))
    n <- as.integer(3*sqrt(k))+1
  } else if(is.null(k) || is.null(n)) {
    stop("Please specify both n and k!")
  }

  if(is.null(adjust)) {
    adjust <- 1
  }

  ndata <- nrow(data)
  colsUsed <- map$colsUsed
  if(is.null(colsUsed)) colsUsed <- (1:ncol(data))
  dim <- length(colsUsed)

  x <- map$xdim
  y <- map$ydim

  if (n<1) {
    stop("Perplexity should be at least 1!")
  }

  if(n>k) {
    stop("Perplexity too high!")
  }
    
  if (k<3) {
    stop("Use at least 3 neighbors for sane results!")
  }

  if (k>(x*y)) {
    stop("Too many neighbors!")
  }

  if(adjust<0) {
    stop("adjust must not be negative!");
  }

  #convert to indexes
  n <- n-1
  k <- k-1

  if(!is.null(importance))
  	points <- t(data[,colsUsed] * rep(importance, each=nrow(data)))
  else
  	points <- t(data[,colsUsed])

  if(!is.null(importance))
  	codes <- t(map$codes * rep(importance, each=nrow(map$codes)))
  else
  	codes <- t(map$codes)

  embedding <- matrix(0, nrow=nrow(data), ncol=2)

  res <- .C("C_embedSOM",
    pn=as.integer(ndata),
    pdim=as.integer(dim),

    pperp=as.integer(n),
    pneighbors=as.integer(k),
    padjust=as.single(adjust),
    
    # the function now relies on the grid being arranged
    # reasonably, indexed row-by-row. If that changes, it is
    # necessary to pass in the map$grid as well.
    pxdim=as.integer(x),
    pydim=as.integer(y),

    points=as.single(points),
    koho=as.single(codes),
    embedding=as.single(embedding))

  matrix(res$embedding, nrow=nrow(data), ncol=2)
}