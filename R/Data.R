#' Set or Query Data and Parameters
#'
#' This function is used to set or query parameters and their attributes.
#'
#' @param option character.
#'   Parameter name, see \sQuote{Parameters} section.
#' @param value
#'   Parameter value specified for \code{option} (optional)
#' @param which.attr character.
#'   A non-empty character string specifying which attribute is to be accessed.
#' @param clear.proj logical.
#'   If true, basic graphical user interface (\acronym{GUI}) preferences will be saved and all other data removed.
#' @param clear.data logical.
#'   If true, only datasets will be removed.
#' @param replace.all list.
#'   A replacement list of parameter values.
#'
#' @section Data:
#' Imported unprocessed data is saved to the data frame \code{data.raw}, see \code{\link{ImportText}}.
#' Processed point data is saved to the data frame \code{data.pts},
#' and interpolated surface data is saved to the list \code{data.grd}.
#'
#' @section Parameters:
#' Parameters undefined elsewhere in the help documentation include:
#' \describe{
#'   \item{\code{ver}}{package version number}
#'   \item{\code{win.loc}}{default horizontal and vertical location for \acronym{GUI} placement in pixels.}
#' }
#'
#' @return If \code{value} is given, the object specified by \code{option} is returned.
#' A \code{NULL} value is returned for objects not yet assigned a value and where no default value is available.
#' Default values are specified internally within this function.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @keywords sysdata
#'
#' @export
#'
#' @examples
#' # set a parameter
#' Data("test1", 3.14159265)
#' Data("test2", list(id = "PI", val = 3.14159265))
#'
#' # retrieve a parameter value
#' Data("test1")
#' Data("test2")
#' Data(c("test2", "id"))
#' Data(c("test2", "val"))
#'
#' # get all parameter values
#' d <- Data()
#'
#' # remove all saved parameter values
#' Data(replace.all = list())
#'
#' # recover saved parameter values
#' Data(replace.all = d)
#'

Data <- local({

  # store data locally
  dat <- list()

  # set default values
  default <- list("win.loc"         = NULL,
                  "default.dir"     = getwd(),
                  "palette.pts"     = function(n, c=80, l=60, start=0, end=300) {
                                        colorspace::rainbow_hcl(n, c, l, start, end)
                                      },
                  "palette.grd"     = function(n, h=c(300, 75), c.=c(35, 95), l=c(15, 90),
                                               power=c(0.8, 1.2)) {
                                        colorspace::heat_hcl(n, h, c., l, power)
                                      },
                  "crs"             = sp::CRS(as.character(NA)),
                  "sep"             = "\t",
                  "cex.pts"         = 1,
                  "nlevels"         = NULL,
                  "asp.yx"          = NULL,
                  "asp.zx"          = NULL,
                  "legend.loc"      = NULL,
                  "scale.loc"       = NULL,
                  "arrow.loc"       = NULL,
                  "scale.loc"       = NULL,
                  "bg.lines"        = 0,
                  "useRaster"       = 1,
                  "contour.lines"   = 0,
                  "dms.tick"        = 0,
                  "make.intervals"  = 0,
                  "proportional"    = 0,
                  "quantile.breaks" = 0,
                  "draw.key"        = 0,
                  "max.dev.dim"     = c(43L, 56L))

  function(option, value, which.attr=NULL, clear.proj=FALSE, clear.data=FALSE, replace.all=NULL) {

    # replace all values
    if (is.list(replace.all)) {
      dat <<- replace.all
      return(invisible())
    }

    # save parameters
    if (clear.proj || clear.data) {
      save.params <- if (clear.data) names(default) else c("win.loc", "default.dir")
      save.params <- save.params[save.params %in% names(dat)]
      dat <<- sapply(save.params, function(i) list(dat[[i]]))
      return(invisible())
    }

    # return all data
    if (missing(option)) return(dat)

    # check indices for numeric option elements
    if (is.numeric(option)) {
      option <- sapply(option, as.integer)
      option.new <- option[1L]
      if (option.new > length(dat)) option.new <- NULL
      if (!is.null(option.new) && length(option) > 1) {
        for (i in 2:length(option)) {
          if (option[i] > length(dat[[option.new[-i]]]))
            break
          else
            option.new <- c(option.new, option[i])
        }
      }

    # determine numeric indices from character option element
    } else {
      idx <- match(option[1], names(dat))
      option.new <- idx
      if (is.na(option.new)) option.new <- NULL
      if (!is.null(option.new) && length(option) > 1) {
        for (i in 2:length(option)) {
          idx <- match(option[i], names(dat[[option.new[-i]]]))
          if (is.na(idx)) break
          option.new <- c(option.new, idx)
        }
      }
    }

    # determine number of options
    noption <- length(option)
    noption.new <- length(option.new)

    # return value
    if (missing(value)) {
      if (noption.new < noption) {
        if (noption == 1 && option %in% names(default))
          return(default[[option]])
        else
          return(NULL)
      }
      if (is.null(which.attr))
        return(dat[[option.new]])
      else
        return(attr(dat[[option.new]], which.attr, exact=TRUE))

    # set value
    } else {
      if (noption.new == noption || (noption.new == (noption - 1)
          && is.list(if (is.null(option.new)) dat else dat[[option.new]]))) {
        if (is.null(which.attr))
          dat[[option]] <<- value
        else
          attr(dat[[option]], which.attr) <<- value
      }
    }
  }
})
