

function Ontology(url, auth, auth_cb) {

    var _url = url;

    var _auth = auth ? auth : { 'token' : '',
                                'user_id' : ''};
    var _auth_cb = auth_cb;


    this.get_goidlist = function(geneIDList, domainList, ecList)
    {
        var resp = json_call_ajax_sync("Ontology.get_goidlist", [geneIDList, domainList, ecList]);

        return resp[0];
    }

    this.get_goidlist_async = function(geneIDList, domainList, ecList, _callback, _error_callback)
    {
        json_call_ajax_async("Ontology.get_goidlist", [geneIDList, domainList, ecList], 1, _callback, _error_callback)
    }

    this.get_go_description = function(goIDList)
    {
        var resp = json_call_ajax_sync("Ontology.get_go_description", [goIDList]);

        return resp[0];
    }

    this.get_go_description_async = function(goIDList, _callback, _error_callback)
    {
        json_call_ajax_async("Ontology.get_go_description", [goIDList], 1, _callback, _error_callback)
    }

    this.get_go_enrichment = function(geneIDList, domainList, ecList, type, ontologytype)
    {
        var resp = json_call_ajax_sync("Ontology.get_go_enrichment", [geneIDList, domainList, ecList, type, ontologytype]);

        return resp[0];
    }

    this.get_go_enrichment_async = function(geneIDList, domainList, ecList, type, ontologytype, _callback, _error_callback)
    {
        json_call_ajax_async("Ontology.get_go_enrichment", [geneIDList, domainList, ecList, type, ontologytype], 1, _callback, _error_callback)
    }

    /*
     * JSON call using jQuery method.
     */

    function json_call_ajax_sync(method, params)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
                    'id': String(Math.random()).slice(2),
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
        var code;

	var token = _auth.token;
	if (_auth_cb)
	{
	    token = _auth_cb();
	}

        var x = jQuery.ajax({
		"async": false,
		dataType: "text",
		url: _url,
		beforeSend: function (xhr){
		    if (token)
		    {
			xhr.setRequestHeader('Authorization', _auth.token);
		    }
		},
		success: function (data, status, xhr) { resp_txt = data; code = xhr.status },
		error: function(xhr, textStatus, errorThrown) { resp_txt = xhr.responseText, code = xhr.status },
		data: body,
		processData: false,
		type: 'POST',
	    });

        var result;

        if (resp_txt)
        {
            var resp = JSON.parse(resp_txt);
            
            if (code >= 500)
            {
                throw resp.error;
            }
            else
            {
                return resp.result;
            }
        }
        else
        {
            return null;
        }
    }

    function json_call_ajax_async(method, params, num_rets, callback, error_callback)
    {
        var rpc = { 'params' : params,
                    'method' : method,
                    'version': "1.1",
                    'id': String(Math.random()).slice(2),
        };
        
        var body = JSON.stringify(rpc);
        var resp_txt;
        var code;
        
	var token = _auth.token;
	if (_auth_cb)
	{
	    token = _auth_cb();
	}

        var x = jQuery.ajax({
		"async": true,
		dataType: "text",
		url: _url,
		beforeSend: function (xhr){
		    if (token)
		    {
			xhr.setRequestHeader('Authorization', token);
		    }
		},
		success: function (data, status, xhr)
		{
		    resp = JSON.parse(data);
		    var result = resp["result"];
		    if (num_rets == 1)
		    {
			callback(result[0]);
		    }
		    else
		    {
			callback(result);
		    }
                    
		},
		error: function(xhr, textStatus, errorThrown)
		{
		    if (xhr.responseText)
		    {
			resp = JSON.parse(xhr.responseText);
			if (error_callback)
			{
			    error_callback(resp.error);
			}
			else
			{
			    throw resp.error;
			}
		    }
		},
		data: body,
		processData: false,
		type: 'POST',
	    });
    }
}


