# Google OAuth 2.0 Setup Guide

This guide will help you set up Google OAuth 2.0 authentication for your cinema management system.

## Prerequisites

- Google Cloud Platform account
- Access to Google Cloud Console
- Your application running on a web server

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown and select "New Project"
3. Enter a project name (e.g., "Cinema Management System")
4. Click "Create"

## Step 2: Enable Google+ API

1. In the Google Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Google+ API" and click on it
3. Click "Enable"

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" for user type
3. Fill in the required fields:
   - **App name**: Cinema Management System
   - **User support email**: Your email address
   - **Developer contact information**: Your email address
4. Click "Save and Continue"
5. Skip the "Scopes" step (we'll use default scopes)
6. Click "Save and Continue"
7. Skip the "Test users" step
8. Click "Save and Continue"

## Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Choose "Web application" as the application type
4. Set the **Authorized redirect URIs** to:
   ```
   http://localhost:8080/your-app/GoogleAuthCallback.jsp
   ```
   Replace `your-app` with your actual application context path.
5. Click "Create"
6. **Important**: Copy the **Client ID** and **Client Secret** - you'll need these for configuration

## Step 5: Configure Your Application

1. Open `src/java/utils/GoogleOAuthConfig.java`
2. Replace the placeholder values:
   ```java
   public static final String CLIENT_ID = "YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com";
   public static final String CLIENT_SECRET = "YOUR_ACTUAL_CLIENT_SECRET";
   ```
3. Update the redirect URI to match your application:
   ```java
   public static final String REDIRECT_URI = "http://localhost:8080/your-app/GoogleAuthCallback.jsp";
   ```

## Step 6: Add Required Dependencies

Download the following JAR files and place them in your `lib` folder:

### Required JAR Files:
- `google-api-client-1.32.1.jar`
- `google-http-client-1.43.3.jar`
- `google-http-client-jackson2-1.43.3.jar`
- `google-oauth-client-1.32.1.jar`
- `google-oauth-client-jetty-1.32.1.jar`
- `google-api-services-oauth2-v2-rev157-1.25.0.jar`
- `jackson-core-2.15.2.jar`
- `jackson-databind-2.15.2.jar`
- `jackson-annotations-2.15.2.jar`

### Download Links:
- [Maven Central Repository](https://mvnrepository.com/)
- Search for the above JAR files and download them

## Step 7: Test the Integration

1. Start your application server
2. Navigate to `http://localhost:8080/your-app/signup.jsp`
3. Click "Sign up with Google"
4. You should be redirected to Google's OAuth consent screen
5. After granting permission, you should be redirected back to your application

## Troubleshooting

### Common Issues:

1. **"Invalid redirect URI" error**
   - Make sure the redirect URI in Google Cloud Console exactly matches your application's callback URL
   - Check for typos in the URL

2. **"Client ID not found" error**
   - Verify that the Client ID in your configuration matches the one from Google Cloud Console
   - Make sure there are no extra spaces or characters

3. **"Access denied" error**
   - Check that the OAuth consent screen is properly configured
   - Ensure the Google+ API is enabled

4. **Dependencies not found**
   - Make sure all required JAR files are in the `lib` folder
   - Check that the JAR files are added to your project's classpath

### Production Deployment:

When deploying to production:

1. Update the redirect URI in Google Cloud Console to your production domain
2. Update the `REDIRECT_URI` in `GoogleOAuthConfig.java`
3. Consider using environment variables for sensitive configuration
4. Enable HTTPS for security

## Security Notes:

- Never commit your Client Secret to version control
- Use environment variables for sensitive configuration in production
- Regularly rotate your OAuth credentials
- Monitor your OAuth usage in Google Cloud Console

## Support:

If you encounter issues:
1. Check the Google Cloud Console for error logs
2. Verify your application logs for detailed error messages
3. Ensure all dependencies are properly configured
4. Test with a simple OAuth flow first before integrating with your application
