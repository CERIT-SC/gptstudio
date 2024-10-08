#' Streaming message
#'
#' Places an invisible empty chat message that will hold a streaming message.
#' It can be reset dynamically inside a shiny app
#'
#' @import htmlwidgets
#' @inheritParams gptstudio_run_chat_app
#' @inheritParams streamingMessage-shiny
#' @param element_id The element's id
streamingMessage <- function(ide_colors = get_ide_theme_info(), # nolint
                             width = NULL,
                             height = NULL,
                             element_id = NULL) {
  message <- list(
    list(role = "user", content = ""),
    list(role = "assistant", content = "")
  ) |>
    style_chat_history(ide_colors = ide_colors)

  # forward options using x
  x <- list(
    message = htmltools::tags$div(message) |> as.character()
  )

  # create widget
  htmlwidgets::createWidget(
    name = "streamingMessage",
    x,
    width = width,
    height = height,
    package = "gptstudio",
    elementId = element_id
  )
}

#' Shiny bindings for streamingMessage
#'
#' Output and render functions for using streamingMessage within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a streamingMessage
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name streamingMessage-shiny
#'
streamingMessageOutput <- function(outputId, width = "100%", height = NULL) { # nolint
  htmlwidgets::shinyWidgetOutput(outputId, "streamingMessage", width, height, package = "gptstudio")
}

#' @rdname streamingMessage-shiny
renderStreamingMessage <- function(expr, env = parent.frame(), quoted = FALSE) { # nolint
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, streamingMessageOutput, env, quoted = TRUE)
}
