#' ChatGPT in Source
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and
#' grammar of selected text.
#'
#' @export
#'
#' @return This function has no return value.
#'
#' @examples
#' # Select some text in a source file
#' # Then call the function as an RStudio addin
#' \dontrun{
#' gptstudio_chat_in_source()
#' }
gptstudio_chat_in_source_addin <- function() {
  gptstudio_chat_in_source()
}

gptstudio_chat_in_source <- function(task = NULL, keep_selection = TRUE) {
  selection <- get_selection()
  service <- getOption("gptstudio.service")
  model <- getOption("gptstudio.model")
  task <- task %||% create_generic_task()

  instructions <- glue::glue("{task}: {selection}")

  cli::cli_progress_step(
    msg = "Sending query to {service}...",
    msg_done = "{service} responded",
    spinner = TRUE
  )

  cli::cli_progress_update()

  response <-
    gptstudio_create_skeleton(
      service = service,
      prompt  = instructions,
      history = list(),
      stream  = FALSE,
      model   = model
    ) |>
    gptstudio_request_perform()

  text_to_insert <- as.character(response$response)

  if (keep_selection) {
    text_to_insert <- c(selection, text_to_insert)
  }

  cli_process_done()

  insert_text(text_to_insert)
}

create_generic_task <- function() {
  file_ext <- get_file_extension()

  glue::glue(
    "You are an expert on following instructions without making conversation.",
    "Do the task specified after the colon.",
    "Your response will go directly into an open .{file_ext} file in an IDE",
    "without any post processing.",
    "Output only plain text. Do not output markdown.",
    .sep = " "
  )
}

get_file_extension <- function() {
  file_ext <- character(1L)

  tryCatch(expr = {
    doc_path <- rstudioapi::documentPath()
    file_ext <<- tools::file_ext(doc_path)
  }, error = function(e) {
    cli::cli_alert_warning("Current document is not saved. Assuming .R file extension")
    file_ext <<- "R"
  })

  return(file_ext)
}
