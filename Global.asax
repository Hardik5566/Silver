<%@ Application Language="C#" %>

<script runat="server">

    void Application_Start(object sender, EventArgs e) 
    {
        // Code that runs on application startup

    }
    
    void Application_End(object sender, EventArgs e) 
    {
        //  Code that runs on application shutdown

    }
        
    void Application_Error(object sender, EventArgs e) 
    { 
        // Code that runs when an unhandled error occurs

    }

    void Session_Start(object sender, EventArgs e) 
    {
        // Do not set Session["user_id"] here. A value of "0" made every new session look "logged out"
        // and the default 20-minute timeout forced re-login often. user_id is set only in Default.aspx after login.
    }

    void Session_End(object sender, EventArgs e) 
    {
        // Cannot read or write Session here — it is already unloaded. (Previous code that set Session keys was invalid.)
    }

    void Application_PostAcquireRequestState(object sender, EventArgs e)
    {
        // Session is available here — restore login from cookie before any page checks Session["user_id"].
        if (HttpContext.Current != null && HttpContext.Current.Session != null)
            AuthHelper.RestoreSessionFromCookie(HttpContext.Current);
    }
       
</script>
