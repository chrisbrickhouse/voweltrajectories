#' Get DCT coefficients
#'
#' This function returns a data frame with columns representing DCT coefficients
#'   for the data input. Input data must have one row for each data series
#'   and each row must contain only the data. This function currently does
#'   not handle data frames which also have metadata, so users need to handle
#'   the addition of metadata on their end. The function guarantees that
#'   output rows match input rows.
#'
#' @param data data frame with signal observations as columns
#' @param n integer specifying number of DCT coefficients to return, defaults to all
#' @return A data frame of DCT coefficients as columns.
#' @seealso \link[dtt]{dct} which this function wraps.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' getdct(x,n=3) # Get first 3 DCT coefficients
#' @importFrom dtt dct
#' @importFrom utils head
#' @export
getdct <- function(data,n=0) {
  colnum <- ncol(data)
  coldiff <- colnum - n
  if (coldiff < 0) {
    stop("Value of n must be less than the number of data points.")
  } else if (coldiff > 0) {
    zerodf <- data.frame(replicate(coldiff,sample(0,nrow(data),replace=TRUE)))
  }
  out <- apply(data,1,function(r) dct(r))
  if (n != 0) {
    out <- head(out,n)
  }
  out <- t(out)
  if (ncol(out) < colnum) {
    out <- cbind(out,zerodf)
  }
  return(out)
}

#' Get error of a DCT model
#'
#' This function returns the sum of squared errors for a dataset modeled
#'   using a given number of DCT coefficients.
#'
#' @param n integer specifying number of DCT coefficients to use
#' @param data data frame of signal observations as columns
#' @return A numeric representing the sum of squared error for a DCT model
#' @seealso \link[voweltrajectories]{dctprediction} which provides model predictions.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' dcterror(3,x) # Get error of model with 3 DCT coefficients
#' @export
dcterror <- function(n,data) {
  pred = dctprediction(n,data)
  err = sum((data-pred)**2)
  return(err)
}
  
#' Get predictions of a DCT model
#'
#' This function returns the predicted values for a dataset modeled
#'   using a given number of DCT coefficients.
#'
#' @param n integer specifying number of DCT coefficients to use
#' @param data data frame of signal observations as columns
#' @return A matrix containing the predictions of a DCT model
#' @seealso \link[dtt]{dct} which this function wraps.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' dctprediction(3,x) # Get error of model with 3 DCT coefficients
#' @export
dctprediction <- function(n,data) {
  coeffs = getdct(data,n)
  pred = as.data.frame(t(apply(coeffs,1,function(r) dct(r,inverted=TRUE))))
  return(pred)
}

#' Get errors of various numbers of DCT coefficients
#'
#' This function returns a vector of the sum of squared errors for each
#'   number of DCT coefficients. By with no other arguments, it returns
#'   the sum of squares for all numbers of DCT coefficients, that is, from
#'   1 to the number of observations (columns). The function takes
#'   optional start and stop values to limit the number of coefficients
#'   evaluated which can be useful for signals with high sample rates.
#'
#' @param data data frame of signal observations as columns
#' @param start integer specifying the minimum number of coefficients to use; defaults to 1
#' @param stop integer specifying the maximum number of coefficients to use; defaults to all
#' @return A vector of sum of squares for each number of DCT coefficients
#' @seealso \link[voweltrajectories]{dcterror} which this function calls.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' getprederr(x)
#' @export
getprederr <- function(data,start=1,stop=NA) {
  if (is.na(stop)) {
    stop <- ncol(data)
  }
  err = sapply(start:stop, dcterror, data=data)
  return(err)
}

#' Get elbow point of model errors
#'
#' This function returns the index in the given error series which the series has an
#'   elbow point. The elbow point is defined as the maximum absolute estimated second
#'   derivative. IF the error series starts at the error of a model using one DCT
#'   coefficient, the output represents the best number of coefficients to use in
#'   an analysis. If you specify a different starting point
#'   in \link[voweltrajectories]{getprederr}, this will not be the case; it is the user's
#'   responsibility to know the relationship between error series indices and
#'   number of DCT coefficients used.
#'
#' Optionally, it can return the entire estimated second derivative, though this is
#'   deprecated and will be separated in future versions.
#'
#' @param errs vector of sum of squared errors
#' @param series logical; if TRUE returns a vector of second derivative estimates
#' @return A numeric representing the elbow point of a data series
#' @seealso \link[voweltrajectories]{getprederr} whose output this function takes as input.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' err = getprederr(x)
#' getelbow(err)
#' @export
getelbow <- function(errs,series=FALSE) {
  end = length(errs) -1
  secondDeriv = sapply(2:end, function(i) errs[i-1] + errs[i+1] - 2 * errs[i])
  if (series) {
    print("The use of this function to return predicted second erivative")
    print("  will soon be split to a seperate function and should not be")
    print("  considered stable.")
    return(secondDeriv)
  } else {
    n = which(secondDeriv == max(abs(secondDeriv)))
    return(n+1)
  }
}

#' Get distance between two DCT sets
#'
#' This function returns a vector of distances between the DCT coefficient sets
#'   provided to it. The vector index is equivalent to the row index of the
#'   input data frames. The distance is calculated as an n-dimensional
#'   Euclidean distance
#'
#' @param x,y data frame of DCT coefficients
#' @return vector of euclidean distance between rows
#' @seealso \link[voweltrajectories]{getdct} whose output this function takes as input.
#' @examples
#' x = data.frame(replicate(10,rnorm(10,500,50))) # Create arbitrary data
#' y = data.frame(replicate(10,rnorm(10,500,50)))
#' xcoeffs = getdct(x) # Get DCT coefficients
#' ycoeffs = getdct(y)
#' dctdistance(xcoeffs,ycoeffs)
#' @export
dctdistance <- function(x,y) {
  if (nrow(x) != nrow(y)) {
    stop("Data frames must be of the same length")
  }
  sqdiff = (x-y)**2
  ed = apply(sqdiff,1,function(r) sqrt(sum(r)))
  return(ed)
}
