-- Prosody Module for authenticating with OpenID Connect
-- Copyright (C) 2015 István Koren
-- Copyright (C) 2013-2015 Ankit Ramani
-- This code is under the Apache 2.0 license.
-- 
-- Based on code contributed to Prosody in mod_auth_internal_plain and mod_auth_http_async Thanks guys!
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- Copyright (C) 2014 Kim Alvefur
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local usermanager = require "core.usermanager";
local new_sasl = require "util.sasl".new;

local log = module._log;
local host = module.host;

local accounts = module:open_store("accounts");

-- dependencies by OIDC
local json = require "util.json";
local http = require "net.http";
local waiter = require "util.async".waiter;
-- local variables by OIDC
local user_info = {};
local scopes;
local uname;

-- define auth provider
local provider = {};

function provider.test_password(username, token)
	log("debug", "test token for user '%s'", username);
	local wait, done = waiter();
    local code = -1;
    log("debug", "access token %s", token)
        
    -- for making a http request to the userinfo endpoint with token encoded
    http.request("https://api.learning-layers.eu/o/oauth2/userinfo?access_token=" .. http.urlencode(token), nil,
        function(body, _code)
        	user_info = body;
            -- util.json for decoding json data.
            lua_value = json.decode(user_info);
             
            --parsing each and every value of table which has json data
            --for key, value in pairs(lua_value) do print(key, value) end
             
            --username contains valid prosody username with JID
            -- username = lua_value["preferred_username"] .. "@localhost";
            uname = lua_value["preferred_username"];
            
            if not provider.user_exists(uname) then
            	provider.create_user(uname);
            end
            
            code = _code;
            done();
        end
        );
        
        wait();

        if code >= 200 and code <= 299 then
            return true;
        else
            module:log("debug", "OpenID Connect provider returned status code %d", code);
            return nil, "Auth failed. Invalid token.";
        end
end

function provider.get_password(username)
	return nil, "Not supported"
end

function provider.set_password(username, password)
	return nil, "Not supported"
end

function provider.user_exists(username)
	local account = accounts:get(username);
	if not account then
		log("debug", "account not found for username '%s'", username);
		return nil, "Auth failed. Invalid username";
	end
	return true;
end

function provider.users()
	return accounts:users();
end

function provider.create_user(username, password)
	return nil, "Not supported"
end

function provider.delete_user(username)
	return accounts:set(username, nil);
end

function provider.get_sasl_handler()
	return new_sasl(host, {
        plain_test = function(sasl, username, token, realm)
            return provider.test_password(username, token), true;
        end
    });
end

module:provides("auth", provider);

