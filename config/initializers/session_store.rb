# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store, {
    expires_in: 30.days,
    redis_server: {url: Rails.configuration.redis_url, namespace: '_Clarabyte_session'}
}