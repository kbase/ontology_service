

function Ontology(url) {

    var _url = url;
    var deprecationWarningSent = false;
    
    function deprecationWarning() {
        if (!deprecationWarningSent) {
            console.log(
                "WARNING: '*_async' method names will be deprecated",
                "on 2/4/2013. Please use the methods without the",
                "'_async' suffix.");
            deprecationWarningSent = true;
        }
    }


    this.get_goidlist = function(sname, geneIDList, domainList, ecList, _callback, _error_callback) {
        return json_call_ajax_async("Ontology.get_goidlist", [sname, geneIDList, domainList, ecList], 1, _callback, _error_callback);
    };

    this.get_goidlist_async = function(sname, geneIDList, domainList, ecList, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax_async("Ontology.get_goidlist", [sname, geneIDList, domainList, ecList], 1, _callback, _error_callback);
    };

    this.get_go_description = function(goIDList, _callback, _error_callback) {
        return json_call_ajax_async("Ontology.get_go_description", [goIDList], 1, _callback, _error_callback);
    };

    this.get_go_description_async = function(goIDList, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax_async("Ontology.get_go_description", [goIDList], 1, _callback, _error_callback);
    };

    this.get_go_enrichment = function(sname, geneIDList, domainList, ecList, type, _callback, _error_callback) {
        return json_call_ajax_async("Ontology.get_go_enrichment", [sname, geneIDList, domainList, ecList, type], 1, _callback, _error_callback);
    };

    this.get_go_enrichment_async = function(sname, geneIDList, domainList, ecList, type, _callback, _error_callback) {
        deprecationWarning();
        return json_call_ajax_async("Ontology.get_go_enrichment", [sname, geneIDList, domainList, ecList, type], 1, _callback, _error_callback);
    };

    function json_call_ajax_async(method, params, num_rets, callback, error_callback) {
        var deferred = $.Deferred();

        if (typeof callback === 'function') {
           deferred.done(callback);
        }

        if (typeof error_callback === 'function') {
           deferred.fail(error_callback);
        }

        var rpc = {
            params:  params,
            method:  method,
            version: "1.1"
        };
        
        var body = JSON.stringify(rpc);
        jQuery.ajax({
            dataType:    "text",
            url:         _url,
            data:        body,
            processData: false,
            type:        "POST",
            success: function (data, status, xhr) {
                try {
                    var resp = JSON.parse(data);
                    var result = resp.result;
                    if (num_rets === 1) {
                        deferred.resolve(result[0]);
                    } else {
                        deferred.resolve(result);
                    }
                } catch (err) {
                    deferred.reject({
                        status: 503,
                        error: err,
                        url: _url,
                        body: body
                    });
                }
            },
            error: function (xhr, textStatus, errorThrown) {
                if (xhr.responseText) {
                    var resp = JSON.parse(xhr.responseText);
                    deferred.reject(resp.error);
                } else {
                    deferred.reject({
                        message: "Unknown Error"
                    });
                }
            }
        });

        return deferred.promise();
    }
}

