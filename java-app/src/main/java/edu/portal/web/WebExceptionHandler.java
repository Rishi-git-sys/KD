
package edu.portal.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class WebExceptionHandler {

    private static final Logger log =
            LoggerFactory.getLogger(WebExceptionHandler.class);

    @ExceptionHandler({
        DataAccessException.class,
        IllegalArgumentException.class
    })
    public String error(Exception e, Model m) {

        // Log the original exception and full stack trace
        log.error("Request processing failed", e);

        String msg = e.getMessage();

        m.addAttribute(
            "message",
            msg != null && msg.contains("Duplicate")
                ? "You have already applied for this vacancy."
                : msg != null && msg.contains("eligible")
                    ? "You are not eligible for this vacancy."
                    : "The request could not be completed. Please check your input."
        );

        return "error";
    }
}