<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:lmilp="http://scriptores.pl/" version="2.0">
    <xsl:key name="fons" match="tei:bibl" use="@xml:id"/>
    <xsl:key name="abbr" match="tei:choice" use="@xml:id"/>
    <xsl:output method="html" exclude-result-prefixes="#all" xml:space="preserve"/>
    <xsl:param name="lang"/>
    <xsl:template match="node()|text()">
        <xsl:if test="not(self::tei:sense)">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <!-- Przygotowanie definicji do wyświetlenia -->
    <xsl:function name="lmilp:beautyDef">
        <xsl:param name="defString"/>
        <xsl:if test="string-join($defString,'') eq ''">
            <xsl:value-of select="''"/>
        </xsl:if>
        <xsl:if test="string-join($defString,'') ne ''">
            <xsl:analyze-string select="string-join($defString,'')" regex="^[,\.\)]">
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="[,\.\(]$">
                        <xsl:non-matching-substring>
                            <xsl:value-of select="concat(string-join( . , '' ),'')"/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    <xsl:template match="tei:sense[not(parent::tei:note[@type='constr'])]">
        <xsl:variable name="level">
            <xsl:value-of select="count(ancestor::tei:sense)"/>
        </xsl:variable>
        <xsl:variable name="numbering_ancestors">
            <xsl:value-of
                select="if (ancestor::tei:sense) then ( concat(string-join(./ancestor::tei:sense/@n,'_'),'_') ) else ()"
            />
        </xsl:variable>
        <xsl:variable name="numbering">
            <xsl:choose>
                <xsl:when test="string-join (@n,'') ne ''">
                    <xsl:value-of select="translate(@n,'\.','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'0'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="def">
            <xsl:variable name="def1">
                <xsl:if test="$lang ne 'pl'">
                    <xsl:value-of
                        select="lmilp:beautyDef(tei:def[@xml:lang = 'la']//node()[not(self::*[@type='sens' or 'gram' or 'dom']) ] )"
                    />
                </xsl:if>
                <xsl:if test="$lang eq 'pl'">
                    <xsl:value-of
                        select="lmilp:beautyDef(tei:def[@xml:lang = 'pl']//node()[ not( self::*[@type='sens' or 'gram' or 'dom'] ) ] )"
                    />
                </xsl:if>
                <!--<xsl:value-of
                    select="lmilp:beautyDef(tei:def[@xml:lang = 'la']//node()[not(self::*[@type='sens' or 'gram' or 'dom']) ])"
                />-->
                <!--"<xsl:value-of select="tei:def[@xml:lang = 'pl']//node()[not(self::*[@type='sens' or 'gram' or 'dom']) ]"/>"-->
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="normalize-space (string-join ($def1,'') ) ne ''">
                    <xsl:value-of select="$def1"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--<xsl:choose>
<xsl:when test="string-join( tei:label[@type = 'sens'] , '') ne ''">
<xsl:value-of select="tei:label[@type = 'sens']"/>
</xsl:when>
<xsl:when test="string-join( tei:label[@type = 'gram'] ,'') ne '' or (preceding-sibling::tei:def or following-sibling::tei:def)">
<xsl:value-of select="tei:label[@type = 'gram']"/>
</xsl:when>
<xsl:otherwise/>
</xsl:choose>-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sense-label">
            <xsl:value-of
                select=" if (tei:label[@type='sens']) then (tei:label[@type='sens']) else (tei:def/tei:label[@type='sens']) "
            />
        </xsl:variable>
        <xsl:variable name="gram-label">
            <xsl:value-of
                select=" if (tei:label[@type='gram']) then (tei:label[@type='gram']) else (tei:def/tei:label[@type='gram']) "
            />
        </xsl:variable>
        <xsl:variable name="domain-label">
            <xsl:value-of
                select="if (tei:usg[@type='dom']) then (tei:usg[@type='dom']) else (tei:def/tei:usg[@type='dom']) "
            />
        </xsl:variable>
        <xsl:variable name="colloc-label">
            <xsl:value-of
                select="if ( string-join( tei:usg[@type='colloc'] ,'' ) ne '') then (concat ('+ ', string-join( tei:usg[@type='colloc'],'' ) ) ) else ( if (tei:def/tei:usg[@type='colloc'] ne '') then (concat ('+ ', tei:def/tei:usg[@type='colloc']) ) else ( '' ) )"
            />
        </xsl:variable>
        <!-- Jeśli sam nie ma definicji... -->
        <xsl:if test="$def eq ''">
            <xsl:choose>
                <!-- ... jeśli ma potomków -->
                <xsl:when test="./child::tei:sense">
                    <ul class="small-block-grid-1 entry_simple_sense">
                        <li>
                            <span class="expand-block">
                                <i>
                                    <!--<xsl:attribute name="class" select="concat('sense-simple-sub-',if (./tei:sense[tei:def]) then ('plus') else ('minus'),' ','fi-',if (./tei:sense[tei:def]) then ('plus') else ('minus'))"/>-->
                                    <xsl:attribute name="class"
                                        select="concat('fa', ' ', 'fa-plus-square', ' ', 'hidden')"
                                    />
                                </i>
                            </span>
                            <xsl:if test="$numbering ne '' and $numbering ne '0'">
                                <span class="numbering">
                                    <xsl:value-of select="concat($numbering,'. ')"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$sense-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$sense-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$gram-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$gram-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$domain-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$domain-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$colloc-label ne ''">
                                <span class="colloc-label-simple label secondary radius">
                                    <xsl:value-of select="$colloc-label"/>
                                </span>
                            </xsl:if>
                            <xsl:apply-templates/>
                        </li>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <ul class="small-block-grid-1 entry_simple_sense">
                        <xsl:element name="li">
                            <xsl:attribute name="class" select="'sense_simple sense_full entry'"/>
                            <xsl:attribute name="level" select="$level"/>
                            <span class="expand-block">
                                <i>
                                    <!--<xsl:attribute name="class" select="concat('fa', ' ', 'fa-', if (./tei:sense[tei:def]) then ('plus') else ('minus'),'-square', ' ', 'hidden')"/>-->
                                    <xsl:attribute name="class"
                                        select="concat('fa', ' ', 'fa-plus-square', ' ', 'hidden')"
                                    />
                                </i>
                            </span>
                            <xsl:if test="$numbering ne '' and $numbering ne '0'">
                                <span class="numbering">
                                    <xsl:value-of select="concat($numbering,'. ')"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$sense-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$sense-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$gram-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$gram-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$domain-label ne ''">
                                <span class="domain-label-simple label success radius">
                                    <xsl:value-of select="$domain-label"/>
                                </span>
                            </xsl:if>
                            <xsl:if test="$colloc-label ne ''">
                                <span class="colloc-label-simple label secondary radius">
                                    <xsl:value-of select="$colloc-label"/>
                                </span>
                            </xsl:if>
                            <span class="entry_simple_def">
                                <span class="sense-simple-def">
                                    <!--<span class="sense-simple-num">
<xsl:value-of select="concat($numbering,'. ')"/>
</span>-->
                                    <xsl:value-of select="$def"/>
                                    <a
                                        href="{concat('#',concat(if($numbering_ancestors) then ($numbering_ancestors) else (),'sense_',$numbering))}">
                                        <i class="fa fa-hand-o-right"/>
                                    </a>
                                </span>
                            </span>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </ul>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <!-- Jeśli sam ma definicję... -->
        <xsl:if test="$def ne ''">
            <ul class="small-block-grid-1 entry_simple_sense">
                <xsl:element name="li">
                    <xsl:attribute name="class" select="'sense_simple sense_full entry'"/>
                    <xsl:attribute name="level" select="$level"/>
                    <span class="expand-block">
                        <i>
                            <!--<xsl:attribute name="class" select="concat('fa', ' ', 'fa-', if (./tei:sense[tei:def]) then ('plus') else ('minus'),'-square', ' ', 'hidden')"/>-->
                            <xsl:attribute name="class"
                                select="concat('fa', ' ', 'fa-plus-square', ' ', 'hidden')"/>
                        </i>
                    </span>
                    <xsl:if test="$numbering ne '' and $numbering ne '0'">
                        <span class="numbering">
                            <xsl:value-of select="concat($numbering,'. ')"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="$domain-label ne ''">
                        <span class="domain-label-simple label success radius">
                            <xsl:value-of select="$domain-label"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="$sense-label ne ''">
                        <span class="sense-label-simple label success radius">
                            <xsl:value-of select="$sense-label"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="$colloc-label ne ''">
                        <span class="colloc-label-simple label secondary radius">
                            <xsl:value-of select="$colloc-label"/>
                        </span>
                    </xsl:if>
                    <span class="entry_simple_def">
                        <span class="sense-simple-def">
                            <!--<span class="sense-simple-num">
<xsl:value-of select="concat($numbering,'. ')"/>
</span>-->
                            <xsl:value-of select="$def"/>
                            <a class="lemma_link_sign"
                                href="{concat('#',concat(if($numbering_ancestors) then ($numbering_ancestors) else (),'sense_',$numbering))}">
                                <i class="fa fa-hand-o-right"/>
                            </a>
                        </span>
                    </span>
                    <xsl:apply-templates/>
                </xsl:element>
            </ul>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>