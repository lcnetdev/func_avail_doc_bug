xquery version "1.0-ml";

declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace bf            = "http://id.loc.gov/ontologies/bibframe/";
declare namespace bflc          = "http://id.loc.gov/ontologies/bflc/";(: additional terms :)
declare namespace xdmp 			= "http://marklogic.com/xdmp";
declare namespace map           = "http://marklogic.com/xdmp/map";
declare namespace mlerror	    = "http://marklogic.com/xdmp/error";

let $marcxml := xdmp:get-request-body()/node()
let $marcxml := 
    <marcxml:collection xmlns:marcxml="http://www.loc.gov/MARC21/slim">
        { $marcxml }
    </marcxml:collection>

let $options := 
    <options xmlns="xdmp:eval">
        <database>{ xdmp:modules-database() }</database>
    </options>
		
return xdmp:xslt-invoke("works.xsl", document{$marcxml}, (), $options)/element()

