unit UpdateCheck;

interface

uses
  SysUtils, Classes, fpjson, jsonparser;

type
  TUpdateChecker = class
  private
    FCurrentVersion: string;
    fLatestVersion: string;
    FOnUpdateAvailable: TNotifyEvent;
    FOnNoUpdateAvailable: TNotifyEvent;
    FOnError: TGetStrProc;

  public
    constructor Create(CurrentVersion: string);
    function GetLatestReleaseVersionGitee(): string;
    function GetLatestReleaseVersionGitCode(): string;

    property LatestVersion: string read fLatestVersion write fLatestVersion;
  end;

implementation

uses
  fphttpclient, opensslsockets, base64;

// Base64 编码（用于 HTTP Basic Auth）
function Base64Encode(const s: string): string;
begin
  // 使用 FPC base64 单元的 EncodeStringBase64（直接对字符串编码）
  Result := EncodeStringBase64(s);
end;

constructor TUpdateChecker.Create(CurrentVersion: string);
begin
  FCurrentVersion := CurrentVersion;
end;

function TUpdateChecker.GetLatestReleaseVersionGitee(): string;
var
  HttpClient: TFPHttpClient;
  Response: string;
  JSONValue: TJSONData;
  TagNameValue: TJSONData;
  AuthHeader: string;
begin
  Result := '';

  try
    HttpClient := TFPHttpClient.Create(nil);
    try
      HttpClient.AllowRedirect := True;
      // 设置 User-Agent（通过 HTTP 头）
      HttpClient.AddHeader('User-Agent', 'DelphiGiteeApp/1.0');

      // Gitee API 使用 Basic Auth（用户名 + 私人令牌）
      AuthHeader := 'Basic ' + Base64Encode('devcpp:3482128325475042df1f451946d441d8');
      HttpClient.AddHeader('Authorization', AuthHeader);

      Response := HttpClient.Get(
        'https://gitee.com/api/v5/repos/devcpp/devcpp/releases/latest');

      if HttpClient.ResponseStatusCode = 200 then
      begin
        JSONValue := GetJSON(Response);
        try
          if (JSONValue <> nil) and (JSONValue is TJSONObject) then
          begin
            TagNameValue := TJSONObject(JSONValue).Find('tag_name');
            if (TagNameValue <> nil) and (TagNameValue.JSONType = jtString) then
              Result := TagNameValue.AsString;
          end;
        finally
          JSONValue.Free;
        end;
      end;
    finally
      HttpClient.Free;
    end;
  except
    on E: Exception do
      Result := ''; // OpenSSL 缺失或网络错误时静默失败
  end;
end;

function TUpdateChecker.GetLatestReleaseVersionGitCode(): string;
var
  HttpClient: TFPHttpClient;
  Response: string;
  JSONValue: TJSONData;
  TagNameValue: TJSONData;
  URL: string;
begin
  Result := '';

  try
    HttpClient := TFPHttpClient.Create(nil);
    try
      HttpClient.AllowRedirect := True;
      HttpClient.AddHeader('User-Agent', 'DelphiGitCodeApp/1.0');
      HttpClient.AddHeader('Accept', 'application/json');

      // GitCode API 用 URL 参数传递 access_token
      URL := 'https://api.gitcode.com/api/v5/repos/devcpp/devcpp/releases/latest' +
             '?access_token=z-ujmy8AaVUqVd-j-gf8DSKz';

      Response := HttpClient.Get(URL);

      if HttpClient.ResponseStatusCode = 200 then
      begin
        JSONValue := GetJSON(Response);
        try
          if (JSONValue <> nil) and (JSONValue is TJSONObject) then
          begin
            TagNameValue := TJSONObject(JSONValue).Find('tag_name');
            if (TagNameValue <> nil) and (TagNameValue.JSONType = jtString) then
              Result := TagNameValue.AsString;
          end;
        finally
          JSONValue.Free;
        end;
      end;
    finally
      HttpClient.Free;
    end;
  except
    on E: Exception do
      Result := ''; // OpenSSL 缺失或网络错误时静默失败
  end;
end;

end.
