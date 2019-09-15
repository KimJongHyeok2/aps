package com.kjh.aps.security;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.web.firewall.FirewalledRequest;
import org.springframework.security.web.firewall.RequestRejectedException;
import org.springframework.security.web.firewall.StrictHttpFirewall;

public class CustomLoggingHttpFirewall extends StrictHttpFirewall {

	@Override
	public FirewalledRequest getFirewalledRequest(HttpServletRequest request) throws RequestRejectedException {
        try
        {
            return super.getFirewalledRequest(request);
        } catch (RequestRejectedException ex) {
            // Wrap in a new RequestRejectedException with request metadata and a shallower stack trace.
            throw new RequestRejectedException("\n------------------------------------------\nMessage : " + 
            ex.getMessage() + "\n" + "Request URL: " + request.getRequestURL().toString()
            + "\n------------------------------------------")
            {
                private static final long serialVersionUID = 1L;

                @Override
                public synchronized Throwable fillInStackTrace()
                {
                    return this;
                }
            };
        }
	}
	
	@Override
	public HttpServletResponse getFirewalledResponse(HttpServletResponse response) {
		return super.getFirewalledResponse(response);
	}
	
}