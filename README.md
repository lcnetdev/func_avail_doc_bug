# xdmp:function-available() + document() bug?

Bear with this description; this is the oddest thing.

Running MarkLogic 10.0-5.2, variables loaded by an included XSL using `document()` 
will not be present when function-available is invoked but encounters a function 
that is unknown to MarkLogic /and/ also uses the resulting value.

The code in this repository will demonstrate this odd behavior.

## Files

- works.xsl, noworky.xsl, unexpectedly-works.xsl : Files that are modified in the small ways to show the problem.
- Above XSL files `xsl:include` these : var.xsl and included.xsl.
- included.xsl contains XSL processing intstructions.
- vars.xsl : this file contains two three variables, one of which is loaded via `document()`.
- map.xml : file loaded via document()  

## Setup

This uses gradle.  

```bash
cp gradlew-params.default gradlew-params
```

Amend the values as needed.

```bash
./deploy-modules reload
```


## Works as expected

NB: This example does *not* test for a function that MarkLogic will not know about.

```bash
curl -i --user u:p -H "Content-type: application/xml" --data @data/21451813.marcxml.xml http://host:port/works.xqy
```

Correct output:

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
  <bf:Work>
    <bf:adminMetadata>
      <bf:AdminMetadata>
        <bf:generationProcess>
          <bf:GenerationProcess>
            <bf:generationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2021-08-18T16:05:00.15703-04:00</bf:generationDate>
          </bf:GenerationProcess>
        </bf:generationProcess>
      </bf:AdminMetadata>
    </bf:adminMetadata>
    <bf:subject>
      <bf:Place rdf:about="123456#Place651-29">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Place>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-30">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Topic>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-31">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Topic>
    </bf:subject>
  </bf:Work>
</rdf:RDF>
```

Take note of the `madsrdf:isMemberOfMADSScheme` and `bf:source` elements (and their children).

## Does not produce expected output

```bash
curl -i --user u:p -H "Content-type: application/xml" --data @data/21451813.marcxml.xml http://host:port/noworky.xqy
```

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
  <bf:Work>
    <bf:adminMetadata>
      <bf:AdminMetadata>
        <bf:generationProcess>
          <bf:GenerationProcess>
            <bf:generationDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2021-08-18T16:07:34.368327-04:00</bf:generationDate>
          </bf:GenerationProcess>
        </bf:generationProcess>
      </bf:AdminMetadata>
    </bf:adminMetadata>
    <bf:subject>
      <bf:Place rdf:about="123456#Place651-29">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
      </bf:Place>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-30">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
      </bf:Topic>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-31">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
      </bf:Topic>
    </bf:subject>
  </bf:Work>
</rdf:RDF>
```

Note `madsrdf:isMemberOfMADSScheme` and `bf:source` elements are missing.

This is the only difference in the XSL being run (the below is present in
the 'noworky' xsl):

```bash
$ diff src/main/ml-modules/root/works.xsl src/main/ml-modules/root/noworky.xsl
23a24,26
>       <xsl:when test="function-available('date:date-time')">
>         <xsl:value-of select="date:date-time()"/>
>       </xsl:when>
```

## Worked unexpectedely, but had to remove use of variable related to function-available calls

NB: This "unexpectedly works" in that the `madsrdf:isMemberOfMADSScheme` and `bf:source` 
are present, but at the loss of `bf:adminMetadata`.

```bash
curl -i --user u:p -H "Content-type: application/xml" --data @data/21451813.marcxml.xml http://host:port/unexpectedly-works.xqy
```

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
  <bf:Work>
    <bf:subject>
      <bf:Place rdf:about="123456#Place651-29">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Place>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-30">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Topic>
    </bf:subject>
    <bf:subject>
      <bf:Topic rdf:about="123456#Topic650-31">
        <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"/>
        <madsrdf:isMemberOfMADSScheme rdf:resource="http://id.loc.gov/authorities/subjects"/>
        <bf:source>
          <bf:Source rdf:about="http://id.loc.gov/authorities/subjects">
            <bf:code>lcsh</bf:code>
          </bf:Source>
        </bf:source>
      </bf:Topic>
    </bf:subject>
  </bf:Work>
</rdf:RDF>
```

Missing is the use of the variable related to the function-available call.  See
"works" example above.  Here is the diff between this XSL and the one that works.

Add additional function-available call; remove use of variable.

```bash
$ diff src/main/ml-modules/root/works.xsl src/main/ml-modules/root/unexpectedly-works.xsl
23a24,26
>       <xsl:when test="function-available('date:date-time')">
>         <xsl:value-of select="date:date-time()"/>
>       </xsl:when>
51,64d53
<         <bf:adminMetadata>
<             <bf:AdminMetadata>
<               <bf:generationProcess>
<                 <bf:GenerationProcess>
<                   <xsl:if test="$pGenerationDatestamp != ''">
<                     <bf:generationDate>
<                       <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($xs,'dateTime')"/></xsl:attribute>
<                       <xsl:value-of select="$pGenerationDatestamp"/>
<                     </bf:generationDate>
<                   </xsl:if>
<                 </bf:GenerationProcess>
<               </bf:generationProcess>
<             </bf:AdminMetadata>
<         </bf:adminMetadata>
```

