<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %><%@
taglib uri="http://liferay.com/tld/clay" prefix="clay" %><%@
taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %><%@
taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>

<%@ page import="com.liferay.petra.string.StringPool" %><%@
page import="com.liferay.portal.kernel.language.LanguageUtil" %><%@
page import="com.liferay.portal.kernel.util.HtmlUtil" %><%@
page import="com.liferay.portal.kernel.util.PortalUtil" %><%@
page import="com.liferay.portal.kernel.util.Validator" %><%@
page import="com.liferay.portal.kernel.util.WebKeys" %><%@
page import="com.liferay.portal.search.web.internal.search.bar.portlet.SearchBarPortletDisplayContext" %>
<%@ page import="java.net.*" %>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.liferay.portal.kernel.dao.orm.DynamicQueryFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.dao.orm.DynamicQuery"%>
<%@page import="com.liferay.asset.kernel.service.AssetCategoryLocalServiceUtil"%>
<%@page import="com.liferay.asset.kernel.exception.VocabularyNameException"%>
<%@page import="com.liferay.portal.kernel.exception.SystemException"%>
<%@page import="com.liferay.asset.kernel.model.AssetCategory"%>
<%@page import="com.liferay.asset.kernel.service.AssetVocabularyLocalServiceUtil"%>
<%@page import="com.liferay.portal.kernel.dao.orm.PropertyFactoryUtil"%>
<%@page import="com.liferay.asset.kernel.model.AssetVocabulary"%>
<%@page import="com.liferay.document.library.kernel.service.DLFileEntryLocalServiceUtil"%>
<%@page import="com.liferay.document.library.kernel.model.DLFileEntry"%>
<%@page import="com.liferay.document.library.kernel.service.DLFolderLocalServiceUtil"%>
<%@page import="com.liferay.document.library.kernel.model.DLFolder"%>
<%@page import="com.liferay.document.library.kernel.model.DLFolderConstants"%>
<%@page import="com.liferay.portal.kernel.util.HttpUtil"%>
<%@page import="com.liferay.portal.kernel.util.PropsUtil" %>
<%@page import="javax.servlet.http.HttpServletRequest" %>

<liferay-theme:defineObjects />
<portlet:defineObjects />

<%
String randomNamespace = PortalUtil.generateRandomKey(request, "portlet_search_bar") + StringPool.UNDERLINE;

SearchBarPortletDisplayContext searchBarPortletDisplayContextCustom = (SearchBarPortletDisplayContext)java.util.Objects.requireNonNull(request.getAttribute(WebKeys.PORTLET_DISPLAY_CONTEXT));


long userId=themeDisplay.getUserId();


//ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(com.liferay.portal.kernel.util.WebKeys.THEME_DISPLAY);

// List<AssetCategory> topic=getCategoryByVocabularyName(themeDisplay.getScopeGroupId(),"Topic"); //AssetCategoryFinderUtil.findByG_N(groupId, "Topic");
List<AssetCategory> project=getCategoryByVocabularyName(themeDisplay.getScopeGroupId(),"Project");//AssetCategoryFinderUtil.findByG_N(groupId, "Project");
List<AssetCategory> contentType=getCategoryByVocabularyName(themeDisplay.getScopeGroupId(),"Content Type");//AssetCategoryFinderUtil.findByG_N(groupId, "Content Type");
List<AssetCategory> classification=getCategoryByVocabularyName(themeDisplay.getScopeGroupId(),"Classification");//AssetCategoryFinderUtil.findByG_N(groupId, "Content Type");
List<AssetCategory> year = new ArrayList<AssetCategory>();
for(AssetCategory assetCategory:classification){
	if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0 && assetCategory.getName().equalsIgnoreCase("Year")){
		for(AssetCategory assetChildCategory:AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId())){
			year.add(assetChildCategory);
		}
	}
}

year = year.stream().sorted((a1, a2) -> a2.getName().compareTo(a1.getName())).collect(java.util.stream.Collectors.toList());

%>

<%!
public static List<AssetCategory> getCategorybasedOnVoc(String vocabularyName){
	List<AssetVocabulary> vocabularies = new ArrayList();
    List<AssetCategory> categories = new ArrayList();

    DynamicQuery queryVocabularies = DynamicQueryFactoryUtil.forClass(
            AssetVocabulary.class).add(
            PropertyFactoryUtil.forName("name").eq(vocabularyName)); // first search for vocabulary
    try {
        vocabularies = AssetVocabularyLocalServiceUtil.dynamicQuery(queryVocabularies, 0, 1);
    //   System.out.println("vac id..."+vocabularies.get(0).getVocabularyId());

        if (vocabularies.size() < 1) {
            return categories;
        }

        DynamicQuery queryCategories = DynamicQueryFactoryUtil.forClass(
                AssetCategory.class).add(
                PropertyFactoryUtil.forName("vocabularyId").eq(
                        vocabularies.get(0).getVocabularyId())); // then get all categories matching the vocabulary
                     //   System.out.println("queryCategories id..."+queryCategories);
        categories = AssetVocabularyLocalServiceUtil.dynamicQuery(queryCategories, 0, 100); // let's get some to show
     //   System.out.println("categories..vac."+categories.size());
    } catch (SystemException e) {
    	e.printStackTrace();
    }
    return categories;
	
}

public static List<AssetCategory> getCategoryByName(String categoryName){
    List<AssetCategory> categories = new ArrayList();
    DynamicQuery query = DynamicQueryFactoryUtil.forClass(
            AssetCategory.class).add(PropertyFactoryUtil.forName("name").eq(categoryName));
   
    try {
        categories = AssetCategoryLocalServiceUtil.dynamicQuery(query, 0, 1); // we only want to first one
     //   System.out.println("categories..."+categories.size());
    } catch (SystemException e) {
    	e.printStackTrace();
    }

    return categories;
	
}
public static List<AssetCategory> getCategoryByVocabularyName(long groupId,String vocName){
	List<AssetCategory> categoryList=null;
	AssetVocabulary vocabulary=null;
	long gid=groupId;
	try{
	 vocabulary=AssetVocabularyLocalServiceUtil.getGroupVocabulary(groupId, vocName);
	 
	}catch(Exception e){
		e.printStackTrace();
		return null;
	}
	
	if(Validator.isNotNull( vocabulary)){
	long vocabularyId=vocabulary.getVocabularyId();
	long parentId=0;
//	System.out.println("Vocabulary id.."+vocabularyId);
	/* DynamicQuery queryCategories = DynamicQueryFactoryUtil.forClass(
             AssetCategory.class).add(
             PropertyFactoryUtil.forName("vocabularyId").eq(
            		 vocabularyId)); // then get all categories matching the vocabulary
                     System.out.println("queryCategories id..."+queryCategories);
                     categoryList = AssetVocabularyLocalServiceUtil.dynamicQuery(queryCategories, 0, 100); // let's get some to show
                     System.out.println("categoryList...."+categoryList.size()); 
	 */ try { 
	// categoryList=AssetCategoryLocalServiceUtil.getVocabularyCategories(parentId,vocabularyId, -1, -1, null);
	 categoryList=AssetCategoryLocalServiceUtil.getVocabularyRootCategories(vocabularyId, -1, -1, null);
	//  System.out.println("categoryList...."+vocName+"....."+categoryList.size());
	}catch(Exception e){
	e.printStackTrace();
	return null;
	} 
	}
	return categoryList;
}

public static String categoryString(List<AssetCategory> rootAssetCateogoryList){
	StringBuilder sb = new StringBuilder();
	for(AssetCategory assetCategory:rootAssetCateogoryList){
		sb.append("<option value='"+assetCategory.getName()+"'>");
		sb.append(assetCategory.getName());
		sb.append("</option>");
		sb.append(getChildCategory(assetCategory.getCategoryId(),StringPool.DASH));
	}
	//System.out.println("final string ..."+sb.toString());
	return sb.toString();
}
public static String getChildCategory(long parentCategoryId,String dash){
	StringBuilder sb = new StringBuilder();
	if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(parentCategoryId)>0){
	List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(parentCategoryId);
	for(AssetCategory assetCategory:childcategoryList){
		sb.append("<option value='"+assetCategory.getName()+"'>"+dash);
		sb.append(assetCategory.getName());
		sb.append("</option>");
		sb.append(getChildCategory(assetCategory.getCategoryId(),dash+StringPool.DASH));
		}
	//System.out.println("child  string ..."+sb.toString());
		return sb.toString();
	}else{
		return StringPool.BLANK;
	}
}

    public String printNotNull(String value){
        return value == null ? "" :  value.trim();
    }

    public boolean isMatched(String given, String received){
        return given.equalsIgnoreCase(received);
    }

	%>

<c:choose>
	<c:when test="<%= searchBarPortletDisplayContextCustom.isDestinationUnreachable() %>">
		<div class="alert alert-info text-center">
			<liferay-ui:message key="this-search-bar-is-not-visible-to-users-yet" />

			<aui:a href="javascript:;" onClick="<%= portletDisplay.getURLConfigurationJS() %>"><liferay-ui:message key="set-up-its-destination-to-make-it-visible" /></aui:a>
		</div>
	</c:when>
	<c:otherwise>
		<aui:form action="<%= searchBarPortletDisplayContextCustom.getSearchURL() %>" method="get" name="fm">
			<c:if test="<%= !Validator.isBlank(searchBarPortletDisplayContextCustom.getPaginationStartParameterName()) %>">
				<input class="search-bar-reset-start-page" name="<%= searchBarPortletDisplayContextCustom.getPaginationStartParameterName() %>" type="hidden" value="0" />
			</c:if>

			<aui:fieldset cssClass="search-bar">
				<aui:input cssClass="search-bar-empty-search-input" name="emptySearchEnabled" type="hidden" value="<%= searchBarPortletDisplayContextCustom.isEmptySearchEnabled() %>" />

				<div class="input-group <%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() ? "search-bar-scope" : "search-bar-simple" %>">
					<c:choose>
						<c:when test="<%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() %>">
							<aui:input cssClass="search-bar-keywords-input" data-qa-id="searchInput" id="<%= randomNamespace + HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>" label="" name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>" placeholder='<%= LanguageUtil.get(request, "search-...") %>' title="search" type="text" useNamespace="<%= false %>" value="<%= searchBarPortletDisplayContextCustom.getKeywords() %>" wrapperCssClass="input-group-item input-group-prepend search-bar-keywords-input-wrapper" />

							<aui:select cssClass="search-bar-scope-select" id="<%= randomNamespace + HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getScopeParameterName()) %>" label="" name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getScopeParameterName()) %>" title="scope" useNamespace="<%= false %>" wrapperCssClass="input-group-item input-group-item-shrink input-group-prepend search-bar-search-select-wrapper">
								<aui:option label="this-site" selected="<%= searchBarPortletDisplayContextCustom.isSelectedCurrentSiteSearchScope() %>" value="<%= searchBarPortletDisplayContextCustom.getCurrentSiteSearchScopeParameterString() %>" />

								<c:if test="<%= searchBarPortletDisplayContextCustom.isAvailableEverythingSearchScope() %>">
									<aui:option label="everything" selected="<%= searchBarPortletDisplayContextCustom.isSelectedEverythingSearchScope() %>" value="<%= searchBarPortletDisplayContextCustom.getEverythingSearchScopeParameterString() %>" />
								</c:if>
							</aui:select>

							<div class="input-group-append input-group-item input-group-item-shrink">
								<clay:button
									ariaLabel='<%= LanguageUtil.get(request, "submit") %>'
									icon="search"
									style="secondary"
									type="submit"
								/>
							</div>
						</c:when>
						<c:otherwise>
							<div class="input-group-item search-bar-keywords-input-wrapper">
								<input class="form-control input-group-inset input-group-inset-after search-bar-keywords-input" data-qa-id="searchInput" id="<%= randomNamespace %><%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>" name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>" placeholder="<%= LanguageUtil.get(request, "search-...") %>" title="<%= LanguageUtil.get(request, "search") %>" type="text" />

								<aui:input name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getScopeParameterName()) %>" type="hidden" value="<%= searchBarPortletDisplayContextCustom.getScopeParameterValue() %>" />

								<div class="input-group-inset-item input-group-inset-item-after">
									<clay:button
										ariaLabel='<%= LanguageUtil.get(request, "submit") %>'
										icon="search"
										style="unstyled"
										type="submit"
									/>
								</div>
							</div>
						</c:otherwise>
					</c:choose>
					<span><a class="link-align" href="javascript:void(0);" id="<portlet:namespace/>displayAdv" > <i id="arrow-toggle" class="icon-chevron-up"></i> Advanced Search</a></span>
				</div>
			</aui:fieldset>
		</aui:form>
		<aui:form action="<%= searchBarPortletDisplayContextCustom.getSearchURL() %>" method="get" name="fm2" id="fm2">
		    <div id='<%= renderResponse.getNamespace() + "advanced-search-blueweb" %>'>
            				 <div class="row search-layout menu-column">
            			      <table>
            			         <tr>
            			            <td>
            			               <div>
            			                  <div>
            			                     <label>Search by :</label>
            			                  </div>
            			                  <div>
            			                     <input class="form-control keyword-align" id="keyword1" placeholder='Keywords' inlineField="<%= true %>"
            			                      label="" name="keyword1" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("keyword1")) %>" title="Keywords" size="30" value="" />
            			                  </div>
            			               </div>
            			            </td>
            			            <td style="vertical-align: bottom;">
            			               <div>
            			                  <aui:col>
            			                     <select class="form-control filterQuery-align" name="operator" id="operator" label="" inlineField="<%= false %>">
            			                        <option label="OR" value="or" <%= (isMatched("or", PortalUtil.getOriginalServletRequest(request).getParameter("operator"))) ? "selected" : ""%>/>
            			                        <option label="AND" value="and" <%= (isMatched("and", PortalUtil.getOriginalServletRequest(request).getParameter("operator"))) ? "selected" : ""%>/>
            			                        <option label="NOT" value="not" <%= (isMatched("not", PortalUtil.getOriginalServletRequest(request).getParameter("operator"))) ? "selected" : ""%>/>
            			                        <option label="NEAR" value="near" <%= (isMatched("near", PortalUtil.getOriginalServletRequest(request).getParameter("operator"))) ? "selected" : ""%>/>
            			                        <option label="CLOSE" value="close" <%= (isMatched("close", PortalUtil.getOriginalServletRequest(request).getParameter("operator"))) ? "selected" : ""%>/>
            			                     </select>
            			                  </aui:col>
            			               </div>
            			            </td>
            			            <td>
            			               <div >
            			                  <div >
            			                     <label>Search by :</label>
            			                  </div>
            			                  <div >
            			                     <input class="form-control keyword-align" id="keyword2" placeholder='Keywords' inlineField="<%= true %>" label=""
            			                      name="keyword3" title="Keywords" size="30" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("keyword2")) %>" />

            			                  </div>
            			               </div>
            			            </td>
            			            <td>
            			               <div >
            			                  <div >
            			                     <label>Search by :</label>
            			                  </div>
            			                  <div>
            			                     <input class="form-control keyword-align" id="title" placeholder='Title'  inlineField="<%= true %>" label="" name="keyword4" title="Title" size="30" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("title")) %>" />
            			                  </div>
            			               </div>
            			            </td>
            			            <td>
            			               <div >
            			                  <div >
            			                     <label>Search by :</label>
            			                  </div>
            			                  <div>
            			                     <input class="form-control keyword-align" id="trackingNumber" placeholder='Tracking Number' inlineField="<%= true %>" label="" name="trackingNumber" title="Tracking Number" size="30" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("trackingNumber")) %>" />
            			                  </div>
            			               </div>
            			            </td>
            			            <td>
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="category1" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Content Type" value="" />
            			                        <%for(AssetCategory assetCategory:contentType){ %>
            			                        <option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>"  <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
            			                           for(AssetCategory childAssetCategory:childcategoryList){ %>
            			                        <option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
            			                           for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
            			                        <option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%}}
            			                           %>
            			                        <%}}} %>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			            <td>
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="category2" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Project" value="" />
            			                        <%for(AssetCategory assetCategory:project){ %>
            			                        <option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
            			                           for(AssetCategory childAssetCategory:childcategoryList){ %>
            			                        <option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
            			                           for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
            			                        <option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%>/>
            			                        <%}}
            			                           %>
            			                        <%}}} %>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			            <td>
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="year" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Year" value="" />
            			                        <%for(AssetCategory assetCategory:year){ %>
            			                        <option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
            			                           for(AssetCategory childAssetCategory:childcategoryList){ %>
            			                        <option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
            			                           for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
            			                        <option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
            			                        <%}}
            			                           %>
            			                        <%}}} %>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			         </tr>
            			      </table>
            			   </div>
            			   <div class="row search-layout menu-column">
            			      <table>
            			         <tr>
            			            <td>
            			               <div>
            			                  <aui:button cssClass="btn-color" type="button" value="Clear" onClick="javascript:clearForm();"/>
            			               </div>
            			            </td>
            			            <td>
            			               <div>
            			                  <aui:button cssClass="btn-color" type="button" value="Save Search" onClick="javascript:saveSearch();"/>
            			               </div>
            			            </td>
            			            <td>
            			               <div>
            			                  <input type="hidden" name="advSearch" value="advSearch" />
            			                  <aui:button cssClass="btn-color" type="button" value="Search" onClick="javascript:search();"/>
            			               </div>
            			            </td>
            			         </tr>
            			      </table>
            			   </div>
            				</div>


		</aui:form>

		<aui:script use="liferay-search-bar">
			new Liferay.Search.SearchBar(A.one('#<portlet:namespace />fm'));
		</aui:script>
	</c:otherwise>
</c:choose>


<script>

    function clearForm(){
        window.location.href="<%= searchBarPortletDisplayContextCustom.getSearchURL() %>";
    }

    function saveSearch(){
       alert("Not implemented yet");
    }

    function search(){
        var keyword1 = $("#keyword1").val();
        var keyword2 = $("#keyword2").val();
        var title = $("#title").val();
        var trackingNumber = $("#trackingNumber").val();

        var operand = $("#operator option:selected").val();
        var category1 = $("#category1 option:selected").val();
        var category2 = $("#category2 option:selected").val();
        var category3 = $("#year option:selected").val();

        var query = "";
        var searchQuery = "";
        if(isNotEmpty(keyword1) && isNotEmpty(operand) && isNotEmpty(keyword2)){
              searchQuery = getWithLogicalOperand(operand, keyword1, keyword2);
              query += "keyword1="+keyword1+"&keyword2="+keyword2+"&operator="+operand;
        } else if(isNotEmpty(keyword1)){
              searchQuery += keyword1;
              query += "keyword1="+keyword1;
        }
        if(isNotEmpty(title)){
            searchQuery += " title_<%=themeDisplay.getLanguageId()%>:"+ title;
            query = appendMyString(query, "title", title);
        }
        if(isNotEmpty(searchQuery))
           query = appendMyString(query, "q", searchQuery);
        if(isNotEmpty(category1)){
           query = appendMyString(query, "category", category1);
           query = appendMyString(query, "category1", category1);
        }if(isNotEmpty(category2)){
           query = appendMyString(query, "category", category2);
           query = appendMyString(query, "category2", category2);
        }if(isNotEmpty(category3)){
           query = appendMyString(query, "category", category3);
           query = appendMyString(query, "category3", category3);
        }if(isNotEmpty(trackingNumber))
           query = appendMyString(query, "trackingNumber", trackingNumber);

        query += (isNotEmpty(query) ? "&" : "")+"search=advanced";
       window.location.href = $('#<portlet:namespace/>fm2').attr('action') + "?" + query;
    }

    function appendMyString(mainString, queryParam, value){
        if(isNotEmpty(value)){
            mainString += (isNotEmpty(mainString) ? ("&"+queryParam+"=") : (queryParam+"=")) +value;
       }
       return mainString;
    }

    function getWithLogicalOperand(operand, keyword1, keyword2){
        switch(operand){
           case "or" : return keyword1 + " " + keyword2;
           case "and" : return keyword1 + " +"+ keyword2;
           case "not" : return keyword1 + " -"+ keyword2;
           case "close" : return keyword1 + " " +keyword2+"~3";
           case "near" : return keyword1 + " "+ keyword2+"~10";
           default : return "";
       }
    }

    function isNotEmpty(value){
        return value != null && value != "";
    }

$(document).ready(function(){
<% if(PortalUtil.getOriginalServletRequest(request).getParameter("search") == null
        || !PortalUtil.getOriginalServletRequest(request).getParameter("search").equalsIgnoreCase("advanced")) {%>
	$("#<portlet:namespace/>advanced-search-blueweb").hide();
	$("#arrow-toggle").toggleClass("icon-chevron-down icon-chevron-up");

<% }%>

    $(".link-align").click(function(){
        $("#<portlet:namespace/>advanced-search-blueweb").toggle();
        $("#arrow-toggle").toggleClass("icon-chevron-up icon-chevron-down");
    });

});
</script>

<style>
.adv-main-div{
display:none;margin-top:-57px;margin-left: 35px;
}
#content .row {
    margin-left: 0px;
    margin-right: 1px !important;
}
.aui .control-group{
margin-bottom:0px !important;
}
.filterClass{
margin-left: 80px!important;
}
.cssClass.filterClass
{
margin-left: 80px!important;
}
.filterAllign{
width: 76px !important;
}
.button-align{
    margin-left: 85px;
    margin-top: 10px;
}
.btn-color{
    background: #5484a1!important;
        color: #f9f9f9!important;
}
.btn-clear{
    background: rgb(128, 128, 128)!important;
    color: white!important;
}
.adv_search_field{
    margin: auto;
    width: 50%;
   
    padding-bottom: 20px!important;
    margin-bottom: 20px!important;
}
.link-align{
    float: right;
    margin-right: 10px;
    margin-top: 12px;
    margin-left: 10px;
    }
    .italic-catg{
    font-style: italic;
}
.first-field{
padding-top:50px;
}
.filterQuery-align{
width:160px;
}
.last-filterQuery{
margin-bottom: 50px!important;
}
.searchcontainer-content{
margin-top:50px;
}
.firstKeyWord{
margin-top:30px;
}
#_com_liferay_portal_search_web_portlet_SearchPortlet_facetNavigation{
margin-top:50px;
    float: left;
    width: 100%;
}
.facet .panel.panel-default {
	width:33.33%;
	float:left;
}
.search-results {
	float:left;
	width:100%;
}
.keyword-align{
width:150px!important;
}
.single-search{
    margin-bottom: 20px!important;
}

.searchTextTitle{
border: 1px solid red;
  outline: none;
}

.btn-default {
    color: #333 !important;
    background-color: #fff !important;
    border-color: #ccc !important;
}
.modal-footer {
    display: block !important;
    padding:15px;
}
.modal-header {
   display: block !important;
   padding:7px;
}

.lfr-search-container-wrapper a{
	color: #064D81;
}

.asset-entry-title .lexicon-icon.lexicon-icon-shortcut {
	height: 3rem;
    width: 3rem;
    margin-top: 10px;
	margin-left: 10px;
}
.asset-entry .asset-entry-title {
	font-size: 18px;
}
.asset-entry .text-default, .asset-entry .asset-entry-date {
	
	color: #1E1E1E;
}
.asset-entry .asset-entry-type {
	width:100px;
}

.row.search-layout.menu-column {
	width: 80%;
}
.list-group-notification .list-group-item {
	background: #F9FAFA;
    border-bottom: 1px solid #ccc;
    border-top: 1px solid #ccc;
    box-shadow: none;
	border-radius:0;
}

.search-bar-keywords-input{
	height:3.6rem;
}


</style>
