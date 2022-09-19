# Copyright (c) 2017-2022 Cloudflare, Inc.
# Licensed under the Apache 2.0 license found in the LICENSE file or at:
#     https://opensource.org/licenses/Apache-2.0

@0x9ac3aeb51d4b6d95;
# capnp structures describing parts of Chrome DevTools Protocol that we need to handle manually.
# These were initially autogenerated, but later tweaked manually so script is not included.

using Cxx = import "/capnp/c++.capnp";
using Json = import "/capnp/compat/json.capnp";

$Cxx.namespace("workerd::cdp");

enum LogType {
  log @0;
  debug @1;
  info @2;
  error @3;
  warning @4;
}

struct Runtime {
  # Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror objects. Evaluation results are returned as mirror object that expose object type, string representation and unique identifier that can be used for further object reference. Original objects are maintained in memory unless they are either explicitly released or are released along with the other objects in their object group.
  using ScriptId = Text; # Unique script identifier.
  struct CallFrame {
    # Stack entry for runtime errors and assertions.
    functionName @0 :Text; # JavaScript function name.
    scriptId @1 :ScriptId; # JavaScript script id.
    url @2 :Text; # JavaScript script name or url.
    lineNumber @3 :Int32; # JavaScript script line number (0-based).
    columnNumber @4 :Int32; # JavaScript script column number (0-based).
  }
  struct StackTrace {
    # Call frames for assertions or error messages.
    description @0 :Text; # String label of this stack trace. For async traces this may be a name of the function that initiated the async call.
    callFrames @1 :List(CallFrame); # JavaScript function name.
    parent @2 :StackTrace; # Asynchronous JavaScript stack trace that preceded this stack, if available.
    parentId @3 :StackTraceId; # Asynchronous JavaScript stack trace that preceded this stack, if available.
  }
  using UniqueDebuggerId = Text; # Unique identifier of current debugger.
  struct StackTraceId {
    # If `debuggerId` is set stack trace comes from another debugger and can be resolved there. This allows to track cross-debugger calls. See `Runtime.StackTrace` and `Debugger.paused` for usages.
    id @0 :Text;
    debuggerId @1 :UniqueDebuggerId;
  }

  struct Event {
    struct ConsoleApiCalled {
      type @0 :LogType;

      args @1 :List(Arg);
      struct Arg $Json.discriminator(name = "type") {
        union {
          undefined @0 :Void;
          string :group $Json.flatten() {
            value @1 :Text;
          }
          # TODO(someday): Other types.
        }
      }

      executionContextId @2 :UInt32;
      timestamp @3 :Float64;
      stackTrace @4 :StackTrace;
    }
  }
}
struct Page {
  # Actions and events related to the inspected page belong to the page domain.
  enum ResourceType {
    # Resource type as it was perceived by the rendering engine.
    document @0 $Json.name("Document");
    stylesheet @1 $Json.name("Stylesheet");
    image @2 $Json.name("Image");
    media @3 $Json.name("Media");
    font @4 $Json.name("Font");
    script @5 $Json.name("Script");
    textTrack @6 $Json.name("TextTrack");
    xhr @7 $Json.name("XHR");
    fetch @8 $Json.name("Fetch");
    eventSource @9 $Json.name("EventSource");
    webSocket @10 $Json.name("WebSocket");
    manifest @11 $Json.name("Manifest");
    other @12 $Json.name("Other");
  }
  using FrameId = Text; # Unique frame identifier.
}
struct Security {
  # Security
  using CertificateId = Int32; # An internal certificate ID value.
  enum MixedContentType {
    # A description of mixed content (HTTP resources on HTTPS pages), as defined by https://www.w3.org/TR/mixed-content/#categories
    blockable @0;
    optionallyBlockable @1 $Json.name("optionally-blockable");
    none @2;
  }
  enum SecurityState {
    # The security level of a page or resource.
    unknown @0;
    neutral @1;
    insecure @2;
    secure @3;
    info @4;
  }
}
struct Network {
  # Network domain allows tracking network activities of the page. It exposes information about http, file, data and other requests and responses, their headers, bodies, timing, etc.
  using LoaderId = Text; # Unique loader identifier.
  using RequestId = Text; # Unique request identifier.
  using TimeSinceEpoch = Float64; # UTC time in seconds, counted from January 1, 1970.
  using MonotonicTime = Float64; # Monotonically increasing time in seconds since an arbitrary point in the past.
  using Headers = Json.Value; # Request / response headers as keys / values of JSON object.
  struct ResourceTiming {
    # Timing information for the request.
    requestTime @0 :Float64; # Timing's requestTime is a baseline in seconds, while the other numbers are ticks in milliseconds relatively to this requestTime.
    proxyStart @1 :Float64; # Started resolving proxy.
    proxyEnd @2 :Float64; # Finished resolving proxy.
    dnsStart @3 :Float64; # Started DNS address resolve.
    dnsEnd @4 :Float64; # Finished DNS address resolve.
    connectStart @5 :Float64; # Started connecting to the remote host.
    connectEnd @6 :Float64; # Connected to the remote host.
    sslStart @7 :Float64; # Started SSL handshake.
    sslEnd @8 :Float64; # Finished SSL handshake.
    workerStart @9 :Float64; # Started running ServiceWorker.
    workerReady @10 :Float64; # Finished Starting ServiceWorker.
    sendStart @11 :Float64; # Started sending request.
    sendEnd @12 :Float64; # Finished sending request.
    pushStart @13 :Float64; # Time the server started pushing request.
    pushEnd @14 :Float64; # Time the server finished pushing request.
    receiveHeadersEnd @15 :Float64; # Finished receiving response headers.
  }
  enum ResourcePriority {
    # Loading priority of a resource request.
    veryLow @0 $Json.name("VeryLow");
    low @1 $Json.name("Low");
    medium @2 $Json.name("Medium");
    high @3 $Json.name("High");
    veryHigh @4 $Json.name("VeryHigh");
  }
  struct Request {
    # HTTP request data.
    url @0 :Text; # Request URL.
    method @1 :Text; # HTTP request method.
    headers @2 :Headers; # HTTP request headers.
    postData @3 :Text; # HTTP POST request data.
    mixedContentType @4 :Security.MixedContentType; # The mixed content type of the request.
    initialPriority @5 :ResourcePriority; # Priority of the resource request at the time request is sent.
    enum ReferrerPolicy {
      # The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
      unsafeUrl @0 $Json.name("unsafe-url");
      noReferrerWhenDowngrade @1 $Json.name("no-referrer-when-downgrade");
      noReferrer @2 $Json.name("no-referrer");
      origin @3;
      originWhenCrossOrigin @4 $Json.name("origin-when-cross-origin");
      sameOrigin @5 $Json.name("same-origin");
      strictOrigin @6 $Json.name("strict-origin");
      strictOriginWhenCrossOrigin @7 $Json.name("strict-origin-when-cross-origin");
    }
    referrerPolicy @6 :ReferrerPolicy; # The referrer policy of the request, as defined in https://www.w3.org/TR/referrer-policy/
    isLinkPreload @7 :Bool; # Whether is loaded via link preload.
  }
  struct SignedCertificateTimestamp {
    # Details of a signed certificate timestamp (SCT).
    status @0 :Text; # Validation status.
    origin @1 :Text; # Origin.
    logDescription @2 :Text; # Log name / description.
    logId @3 :Text; # Log ID.
    timestamp @4 :TimeSinceEpoch; # Issuance date.
    hashAlgorithm @5 :Text; # Hash algorithm.
    signatureAlgorithm @6 :Text; # Signature algorithm.
    signatureData @7 :Text; # Signature data.
  }
  struct SecurityDetails {
    # Security details about a request.
    protocol @0 :Text; # Protocol name (e.g. "TLS 1.2" or "QUIC").
    keyExchange @1 :Text; # Key Exchange used by the connection, or the empty string if not applicable.
    keyExchangeGroup @2 :Text; # (EC)DH group used by the connection, if applicable.
    cipher @3 :Text; # Cipher name.
    mac @4 :Text; # TLS MAC. Note that AEAD ciphers do not have separate MACs.
    certificateId @5 :Security.CertificateId; # Certificate ID value.
    subjectName @6 :Text; # Certificate subject name.
    sanList @7 :List(Text); # Subject Alternative Name (SAN) DNS names and IP addresses.
    issuer @8 :Text; # Name of the issuing CA.
    validFrom @9 :TimeSinceEpoch; # Certificate valid from date.
    validTo @10 :TimeSinceEpoch; # Certificate valid to (expiration) date
    signedCertificateTimestampList @11 :List(SignedCertificateTimestamp); # List of signed certificate timestamps (SCTs).
  }
  struct Response {
    # HTTP response data.
    url @0 :Text; # Response URL. This URL can be different from CachedResource.url in case of redirect.
    status @1 :Int32; # HTTP response status code.
    statusText @2 :Text; # HTTP response status text.
    headers @3 :Headers; # HTTP response headers.
    headersText @4 :Text; # HTTP response headers text.
    mimeType @5 :Text; # Resource mimeType as determined by the browser.
    requestHeaders @6 :Headers; # Refined HTTP request headers that were actually transmitted over the network.
    requestHeadersText @7 :Text; # HTTP request headers text.
    connectionReused @8 :Bool; # Specifies whether physical connection was actually reused for this request.
    connectionId @9 :Float64; # Physical connection id that was actually used for this request.
    remoteIPAddress @10 :Text; # Remote IP address.
    remotePort @11 :Int32; # Remote port.
    fromDiskCache @12 :Bool; # Specifies that the request was served from the disk cache.
    fromServiceWorker @13 :Bool; # Specifies that the request was served from the ServiceWorker.
    encodedDataLength @14 :Float64; # Total number of bytes received for this request so far.
    timing @15 :ResourceTiming; # Timing information for the given request.
    protocol @16 :Text; # Protocol used to fetch this request.
    securityState @17 :Security.SecurityState; # Security state of the request resource.
    securityDetails @18 :SecurityDetails; # Security details for the request.
  }
  struct Initiator {
    # Information about the request initiator.
    enum Type {
      # Type of this initiator.
      parser @0;
      script @1;
      preload @2;
      other @3;
    }
    type @0 :Type; # Type of this initiator.
    stack @1 :Runtime.StackTrace; # Initiator JavaScript stack trace, set for Script only.
    url @2 :Text; # Initiator URL, set for Parser type or for Script type (when script is importing module).
    lineNumber @3 :Float64; # Initiator line number, set for Parser type or for Script type (when script is importing module) (0-based).
  }
  struct Command {
    struct Enable {
      # Enables network tracking, network events will now be delivered to the client.
      struct Params {
        maxTotalBufferSize @0 :Int32; # Buffer size in bytes to use when preserving network payloads (XHRs, etc).
        maxResourceBufferSize @1 :Int32; # Per-resource buffer size in bytes to use when preserving network payloads (XHRs, etc).
      }
      struct Result {}
    }
    struct Disable {
      # Disables network tracking, prevents network events from being sent to the client.
      struct Params {}
      struct Result {}
    }
    struct GetResponseBody {
      # Returns content served for the given request.
      struct Params {
        requestId @0 :RequestId; # Identifier of the network request to get content for.
      }
      struct Result {
        body @0 :Text; # Response body.
        base64Encoded @1 :Bool; # True, if content was sent as base64.
      }
    }
  }
  struct Event {
    struct RequestWillBeSent {
      # Fired when page is about to send HTTP request.
      requestId @0 :RequestId; # Request identifier.
      loaderId @1 :LoaderId; # Loader identifier. Empty string if the request is fetched from worker.
      documentURL @2 :Text; # URL of the document this request is loaded for.
      request @3 :Request; # Request data.
      timestamp @4 :MonotonicTime; # Timestamp.
      wallTime @5 :TimeSinceEpoch; # Timestamp.
      initiator @6 :Initiator; # Request initiator.
      redirectResponse @7 :Response; # Redirect response data.
      type @8 :Page.ResourceType; # Type of this resource.
      frameId @9 :Page.FrameId; # Frame identifier.
    }
    struct ResponseReceived {
      # Fired when HTTP response is available.
      requestId @0 :RequestId; # Request identifier.
      loaderId @1 :LoaderId; # Loader identifier. Empty string if the request is fetched from worker.
      timestamp @2 :MonotonicTime; # Timestamp.
      type @3 :Page.ResourceType; # Resource type.
      response @4 :Response; # Response data.
      frameId @5 :Page.FrameId; # Frame identifier.
    }
    struct DataReceived {
      # Fired when data chunk was received over the network.
      requestId @0 :RequestId; # Request identifier.
      timestamp @1 :MonotonicTime; # Timestamp.
      dataLength @2 :Int32; # Data chunk length.
      encodedDataLength @3 :Int32; # Actual bytes received (might be less than dataLength for compressed encodings).
    }
    struct LoadingFinished {
      # Fired when HTTP request has finished loading.
      requestId @0 :RequestId; # Request identifier.
      timestamp @1 :MonotonicTime; # Timestamp.
      encodedDataLength @2 :Float64; # Total number of bytes received for this request.
      cfResponse @3 :Command.GetResponseBody.Result; # Custom extension to send response body immediately to the client.
    }
  }
}

struct Profiler {

  struct PositionTickInfo {
    line @0 :Int32;
    ticks @1 :Int32;
  }

  struct ProfileNode {
    id @0 :Int32;
    callFrame @1 :Runtime.CallFrame;
    hitCount @2 :Int32;
    children @3 :List(Int32);
    deoptReason @4 :Text;
    positionTicks @5 :List(PositionTickInfo);
  }

  struct Profile {
    nodes @0 :List(ProfileNode);
    startTime @1 :Float64;
    endTime @2 :Float64;
    samples @3 :List(Int32);
    timeDeltas @4 :List(Int32);
  }

  struct Command {
    struct Enable {
      struct Params {}
      struct Result {}
    }
    struct SetSamplingInterval {
      struct Params {
        interval @0 :Int32;
      }
      struct Result {}
    }
    struct Start {
      struct Params {}
      struct Result {}
    }
    struct Stop {
      struct Params {}
      struct Result {
        profile @0 :Profile;
      }
    }
  }
}

struct Error {
  code @0 :Int32;
  message @1 :Text;
}

struct Method(Params, Result) {
  union {
    params @0 :Params;
    result @1 :Result;
    error @2 :Error;
  }
}

struct Command $Json.discriminator(name = "method") {
  id @0 :Int32;
  union {
    unknown @1 :Void;
    networkEnable @2 :Method(Network.Command.Enable.Params, Network.Command.Enable.Result) $Json.name("Network.enable") $Json.flatten();
    networkDisable @3 :Method(Network.Command.Disable.Params, Network.Command.Disable.Result) $Json.name("Network.disable") $Json.flatten();
    networkGetResponseBody @4 :Method(Network.Command.GetResponseBody.Params, Network.Command.GetResponseBody.Result) $Json.name("Network.getResponseBody") $Json.flatten();
    profilerSetSamplingInterval @5 :Method(Profiler.Command.SetSamplingInterval.Params, Profiler.Command.SetSamplingInterval.Result) $Json.name("Profiler.setSamplingInterval") $Json.flatten();
    profilerEnable @6 :Method(Profiler.Command.Enable.Params, Profiler.Command.Enable.Result) $Json.name("Profiler.enable") $Json.flatten();
    profilerStart @7 :Method(Profiler.Command.Start.Params, Profiler.Command.Start.Result) $Json.name("Profiler.start") $Json.flatten();
    profilerStop @8 :Method(Profiler.Command.Stop.Params, Profiler.Command.Stop.Result) $Json.name("Profiler.stop") $Json.flatten();
  }
}

struct Event $Json.discriminator(name = "method", valueName = "params") {
  union {
    networkRequestWillBeSent @0 :Network.Event.RequestWillBeSent $Json.name("Network.requestWillBeSent"); # Fired when page is about to send HTTP request.
    networkResponseReceived @1 :Network.Event.ResponseReceived $Json.name("Network.responseReceived"); # Fired when HTTP response is available.
    networkDataReceived @2 :Network.Event.DataReceived $Json.name("Network.dataReceived"); # Fired when data chunk was received over the network.
    networkLoadingFinished @3 :Network.Event.LoadingFinished $Json.name("Network.loadingFinished"); # Fired when HTTP request has finished loading.

    runtimeConsoleApiCalled @4 :Runtime.Event.ConsoleApiCalled $Json.name("Runtime.consoleAPICalled");
  }
}
