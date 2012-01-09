var serviceApi;
if (serviceApi == undefined) {
	serviceApi = {};
}

serviceApi.getUploadedFileList = function(callback){
	$.getJSON('service/api', {method:"getUploadedFileList"}, callback);
}

serviceApi.sendCancelUploadedAction = function(_id)
{
	$.getJSON('service/api', {method:"cancelUploadedAction", id:_id}, callback);
}

serviceApi.sendCancelAllUploadedAction = function(callback)
{
	$.getJSON('service/api', {method:"cancelAllUploadedAction"}, callback);
}