library(shiny)
library(shinythemes)
library(caret)
library(DT)
library(ggplot2)
library(pROC)
library(randomForest)
library(e1071)
library(nnet)
library(gbm)
library(xgboost)
library(naivebayes)
library(glmnet)
library(rpart.plot)
library(corrplot)
library(shinyWidgets)
library(plotly)
library(reshape2)
library(RColorBrewer)
library(gridExtra)
library(knitr)

# Load dataset
data <- read.csv("heart_failure_clinical_records_dataset.csv")
data$DEATH_EVENT <- factor(data$DEATH_EVENT, levels = c(0,1), labels = c("No","Yes"))

ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Heart Failure Predictive Analytics Dashboard"),
  tabsetPanel(
    tabPanel("Data Explorer",
             DTOutput("data_table"),
             plotOutput("correlation_plot")
    ),
    tabPanel("Model Training",
             pickerInput("algorithms", "Select Algorithms", choices = c(
               "Logistic Regression" = "glm",
               "LDA" = "lda",
               "QDA" = "qda",
               "KNN" = "knn",
               "Naive Bayes" = "naive_bayes",
               "Decision Tree" = "rpart",
               "Random Forest" = "rf",
               "Bagged Trees" = "treebag",
               "Ranger (Fast RF)" = "ranger",
               "Gradient Boosting" = "gbm",
               "SVM Linear" = "svmLinear",
               "SVM Radial" = "svmRadial",
               "Neural Network" = "nnet",
               "XGBoost" = "xgbTree",
               "Elastic Net" = "glmnet"
             ), multiple = TRUE),
             sliderInput("split_ratio", "Train/Test Split Ratio", 0.5, 0.9, 0.7),
             numericInput("cv_folds", "Cross-Validation Folds", 5, min = 2),
             numericInput("seed", "Random Seed", 123, min = 1),
             actionButton("train_models", "Train Models")
    ),
    tabPanel("Model Analytics",
             h4("Model Summaries"),
             verbatimTextOutput("model_results"),
             h4("Training Metrics"),
             DTOutput("train_metrics"),
             h4("Validation Metrics"),
             DTOutput("test_metrics"),
             h4("ROC Analysis"),
             plotlyOutput("roc_plot"),
             h4("Feature Importance (Random Forest)"),
             plotOutput("importance_plot"),
             h4("Training Duration"),
             plotOutput("training_time_plot"),
             h4("Custom Visualization"),
             checkboxGroupInput("selected_models", "Select Models", choices = NULL),
             checkboxGroupInput("selected_metrics", "Select Metrics", 
                                choices = c("Accuracy", "Sensitivity", 
                                            "Specificity", "F1_Score")),
             plotOutput("custom_plot")
    ),
    tabPanel("Model Comparison",
             DTOutput("comparison_table"),
             plotOutput("comparison_plot")
    ),
    tabPanel("Risk Predictor",
             uiOutput("input_ui"),
             actionButton("predict_btn", "Calculate Risk"),
             DTOutput("prediction_output")
    ),
    tabPanel("Model Explanations",
             uiOutput("explain_ui")
    )
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(models = NULL, times = NULL, test_set = NULL, 
                       train_metrics = NULL, test_metrics = NULL)
  
  output$data_table <- renderDT({
    datatable(data, options = list(
      pageLength = 10,
      scrollX = TRUE,
      dom = 'Bfrtip'
    )) %>% formatStyle(names(data), backgroundColor = '#F7FBFF')
  })
  
  output$correlation_plot <- renderPlot({
    nums <- data[sapply(data, is.numeric)]
    corrplot(cor(nums), 
             method = "color",
             tl.cex = 0.9,
             tl.col = "darkblue",
             tl.srt = 45,
             addCoef.col = "black",
             number.cex = 0.7,
             col = colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(100),
             mar = c(0, 0, 2, 0),
             title = "Feature Correlation Matrix")
  })
  
  observeEvent(input$train_models, {
    req(input$algorithms)
    set.seed(input$seed)
    idx <- createDataPartition(data$DEATH_EVENT, p = input$split_ratio, list = FALSE)
    train_set <- data[idx, ]
    test_set <- data[-idx, ]
    rv$test_set <- test_set
    
    if (length(unique(train_set$DEATH_EVENT)) < 2) {
      showNotification("Training set contains single class. Adjust split ratio or seed.", 
                       type = "error")
      return(NULL)
    }
    
    prob_models <- c("glm", "lda", "qda", "knn", "naive_bayes", "rpart", 
                     "rf", "treebag", "gbm", "svmLinear", "svmRadial", 
                     "nnet", "xgbTree", "glmnet", "ranger")
    
    algos <- input$algorithms
    times <- numeric(length(algos))
    models <- vector("list", length(algos))
    
    train_metric_list <- list()
    test_metric_list <- list()
    
    withProgress(message = "Training Models...", value = 0, {
      for (i in seq_along(algos)) {
        method <- algos[i]
        incProgress(1/length(algos), detail = paste("Training:", method))
        start_time <- Sys.time()
        
        ctrl <- trainControl(method = "cv", number = input$cv_folds,
                             classProbs = (method %in% prob_models),
                             summaryFunction = if (method %in% prob_models) twoClassSummary else defaultSummary)
        metric <- if (method %in% prob_models) "ROC" else "Accuracy"
        
        model <- train(DEATH_EVENT ~ ., data = train_set, method = method,
                       trControl = ctrl, metric = metric)
        
        models[[i]] <- model
        times[i] <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
        
        # Training metrics
        train_preds <- predict(model, train_set)
        train_cm <- confusionMatrix(train_preds, train_set$DEATH_EVENT)
        train_metric_list[[i]] <- data.frame(
          Algorithm = method,
          Accuracy = round(train_cm$overall["Accuracy"], 3),
          Sensitivity = round(train_cm$byClass["Sensitivity"], 3),
          Specificity = round(train_cm$byClass["Specificity"], 3),
          F1_Score = round(2 * (train_cm$byClass["Sensitivity"] * 
                                  train_cm$byClass["Pos Pred Value"]) / 
                             (train_cm$byClass["Sensitivity"] + 
                                train_cm$byClass["Pos Pred Value"]), 3)
        )
        
        # Validation metrics
        test_preds <- predict(model, test_set)
        test_cm <- confusionMatrix(test_preds, test_set$DEATH_EVENT)
        # F1 Score Hesaplama Güncellemesi (zaten kodda var ama kontrol için)
        test_metric_list[[i]] <- data.frame(
          Algorithm = method,
          Accuracy = round(test_cm$overall["Accuracy"], 3),
          Sensitivity = round(test_cm$byClass["Sensitivity"], 3),
          Specificity = round(test_cm$byClass["Specificity"], 3),
          F1_Score = round(2 * (test_cm$byClass["Sensitivity"] * 
                                  test_cm$byClass["Pos Pred Value"]) / 
                             (test_cm$byClass["Sensitivity"] + 
                                test_cm$byClass["Pos Pred Value"]), 3)
        )
      }
    })
    
    rv$models <- setNames(models, algos)
    rv$times <- data.frame(algorithm = factor(algos, algos), time_sec = times)
    rv$train_metrics <- do.call(rbind, train_metric_list)
    rv$test_metrics <- do.call(rbind, test_metric_list)
    
    updateCheckboxGroupInput(session, "selected_models", choices = algos)
    
    output$model_results <- renderPrint({
      lapply(rv$models, function(mod) {
        cat("=== ", mod$method, " ===\n"); print(mod); cat("\n")
      })
    })
    
    output$train_metrics <- renderDT({
      datatable(rv$train_metrics, rownames = FALSE,
                options = list(dom = 't', scrollX = TRUE)) %>%
        formatStyle(names(rv$train_metrics), backgroundColor = '#ECF0F5')
    })
    
    output$test_metrics <- renderDT({
      datatable(rv$test_metrics, rownames = FALSE,
                options = list(dom = 't', scrollX = TRUE)) %>%
        formatStyle(names(rv$test_metrics), backgroundColor = '#ECF0F5')
    })
    
    output$roc_plot <- renderPlotly({
      roc_list <- lapply(rv$models, function(m) {
        if (m$method %in% prob_models) {
          roc_obj <- roc(response = rv$test_set$DEATH_EVENT,
                         predictor = predict(m, rv$test_set, type = "prob")[, "Yes"])
          data.frame(FPR = 1 - roc_obj$specificities,
                     TPR = roc_obj$sensitivities,
                     Algorithm = m$method)
        } else NULL
      })
      
      df_roc <- do.call(rbind, Filter(Negate(is.null), roc_list))
      
      p <- ggplot(df_roc, aes(x = FPR, y = TPR, color = Algorithm)) +
        geom_line(size = 0.8) +
        geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray40") +
        scale_color_manual(values = colorRampPalette(brewer.pal(8, "Dark2"))(length(unique(df_roc$Algorithm)))) +
        labs(title = "ROC Curve Comparison",
             x = "False Positive Rate (1 - Specificity)",
             y = "True Positive Rate (Sensitivity)") +
        theme_minimal(base_size = 12) +
        theme(legend.position = "right",
              plot.title = element_text(face = "bold", hjust = 0.5),
              panel.grid.minor = element_blank())
      
      ggplotly(p, tooltip = c("Algorithm", "FPR", "TPR")) %>%
        layout(legend = list(orientation = "h", y = -0.2))
    })
    
    output$importance_plot <- renderPlot({
      req(rv$models$rf)
      imp <- varImp(rv$models$rf)$importance
      imp$Variable <- rownames(imp)
      
      ggplot(imp, aes(x = reorder(Variable, Overall), y = Overall, fill = Overall)) +
        geom_col(width = 0.7) +
        scale_fill_gradient(low = "#4393C3", high = "#D6604D") +
        coord_flip() +
        labs(title = "Random Forest Feature Importance",
             x = NULL, y = "Importance Score") +
        theme_minimal(base_size = 12) +
        theme(legend.position = "none",
              plot.title = element_text(face = "bold"),
              axis.text.y = element_text(color = "darkblue"))
    })
    
    output$training_time_plot <- renderPlot({
      ggplot(rv$times, aes(x = reorder(algorithm, time_sec), y = time_sec, 
                           fill = algorithm)) +
        geom_col(alpha = 0.8) +
        geom_text(aes(label = sprintf("%.1f s", time_sec)), hjust = -0.1, size = 3.5) +
        coord_flip() +
        scale_fill_manual(values = colorRampPalette(brewer.pal(9, "Set1"))(nrow(rv$times))) +
        labs(title = "Model Training Duration", x = NULL, y = "Seconds") +
        theme_minimal(base_size = 12) +
        theme(legend.position = "none",
              plot.title = element_text(face = "bold"),
              axis.text.x = element_blank())
    })
    
    output$comparison_table <- renderDT({
      datatable(rv$test_metrics, rownames = FALSE,
                options = list(scrollX = TRUE)) %>%
        formatStyle(names(rv$test_metrics), backgroundColor = '#ECF0F5')
    })
    
    
    
    # Model Comparison Plot Güncellemesi
    output$comparison_plot <- renderPlot({
      df_m <- melt(rv$test_metrics, id.vars = "Algorithm")
      
      ggplot(df_m, aes(x = value, y = reorder(Algorithm, value), fill = variable)) +
        geom_col(position = "dodge", alpha = 0.8, width = 0.7) +
        geom_text(aes(label = sprintf("%.2f", value)), 
                  position = position_dodge(width = 0.9), 
                  hjust = 1.1, 
                  color = "white", 
                  size = 3.5) +
        scale_fill_brewer(palette = "Set2", name = "Metric") +
        facet_grid(. ~ variable, scales = "free_x") +
        labs(title = "Model Performance Comparison", 
             x = "Metric Value", 
             y = NULL) +
        theme_minimal(base_size = 12) +
        theme(
          plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          axis.title = element_text(face = "bold"),
          axis.text = element_text(face = "bold"),
          legend.title = element_text(face = "bold"),
          strip.text = element_text(face = "bold", size = 12),
          panel.grid.major.y = element_blank(),
          panel.spacing = unit(1, "lines")
        ) +
        scale_x_continuous(expand = expansion(mult = c(0, 0.1)))
    })
    
    # Custom Plot Güncellemesi
    output$custom_plot <- renderPlot({
      req(input$selected_models, input$selected_metrics)
      df_filtered <- subset(rv$test_metrics, Algorithm %in% input$selected_models)
      df_m <- melt(df_filtered, id.vars = "Algorithm")
      df_m <- subset(df_m, variable %in% input$selected_metrics)
      
      ggplot(df_m, aes(x = Algorithm, y = value, fill = variable)) +
        geom_col(position = position_dodge2(preserve = "single"), 
                 alpha = 0.8, 
                 width = 0.8) +
        geom_text(aes(label = sprintf("%.2f", value)), 
                  position = position_dodge2(width = 0.8),
                  vjust = -0.5, 
                  size = 4, 
                  color = "black",
                  fontface = "bold") +
        scale_fill_manual(values = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A")) +
        labs(title = "Custom Model Comparison",
             x = NULL, 
             y = "Metric Value", 
             fill = "Metric") +
        ylim(0, 1) +
        theme_minimal(base_size = 14) +
        theme(
          plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
          axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
          axis.title = element_text(face = "bold"),
          legend.title = element_text(face = "bold", size = 12),
          legend.text = element_text(face = "bold"),
          panel.grid.major.x = element_blank()
        )
    })
    
    output$explain_ui <- renderUI({
      panels <- list()
      
      if ("rpart" %in% names(rv$models)) {
        output$dt_plot <- renderPlot({ 
          rpart.plot(rv$models$rpart$finalModel, 
                     box.palette = "Blues", 
                     shadow.col = "gray",
                     fallen.leaves = FALSE)
        })
        panels[[length(panels)+1]] <- tabPanel("Decision Tree", plotOutput("dt_plot"))
      }
      
      if ("glm" %in% names(rv$models)) {
        coeffs <- coef(summary(rv$models$glm$finalModel))
        glm_eq <- paste0("Logit(p) = ", round(coeffs[1,1],3), " + ", 
                         paste(round(coeffs[-1,1],3), "*", rownames(coeffs)[-1], collapse = " + "))
        output$glm_formula <- renderPrint({ cat(glm_eq) })
        
        coeff_df <- data.frame(
          Variable = rownames(coeffs),
          Coefficient = coeffs[,1]
        )
        
        output$glm_coef_plot <- renderPlot({
          ggplot(coeff_df[-1,], aes(x = reorder(Variable, Coefficient), y = Coefficient)) +
            geom_col(fill = "#67A9CF") +
            coord_flip() + 
            labs(title = "Logistic Regression Coefficients", x = "Feature", y = "Coefficient") +
            theme_minimal(base_size = 12) +
            theme(plot.title = element_text(face = "bold"))
        })
        
        panels[[length(panels)+1]] <- tabPanel("Logistic Regression", 
                                               verbatimTextOutput("glm_formula"), 
                                               plotOutput("glm_coef_plot"))
      }
      
      do.call(navlistPanel, c(panels, list(widths = c(3,9))))
    })
  })
  
  output$input_ui <- renderUI({ 
    req(rv$models)
    do.call(tagList, lapply(setdiff(names(data), "DEATH_EVENT"), function(var) {
      if (is.numeric(data[[var]])) {
        sliderInput(var, var, 
                    min = round(min(data[[var]], na.rm = TRUE),1),
                    max = round(max(data[[var]], na.rm = TRUE),1),
                    value = round(median(data[[var]], na.rm = TRUE),1))
      } else {
        selectInput(var, var, choices = unique(data[[var]]))
      }
    }))
  })
  
  observeEvent(input$predict_btn, {
    req(rv$models)
    newdata <- as.data.frame(lapply(setdiff(names(data), "DEATH_EVENT"), function(var) input[[var]]))
    names(newdata) <- setdiff(names(data), "DEATH_EVENT")
    preds <- lapply(rv$models, predict, newdata = newdata)
    dfp <- data.frame(Algorithm = names(preds), 
                      Prediction = unlist(preds), 
                      stringsAsFactors = FALSE)
    output$prediction_output <- renderDT({
      datatable(dfp, options = list(dom = 't')) %>%
        formatStyle('Prediction', backgroundColor = styleEqual(c("Yes", "No"), c("#FF9999", "#99FF99")))
    })
  })
}

shinyApp(ui, server)