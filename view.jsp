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
<%@page import="javax.portlet.PortletPreferences"%>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil"%>


<liferay-theme:defineObjects />
<portlet:defineObjects />

<%

PortletPreferences pref = renderRequest.getPreferences();
String resultsView = GetterUtil.getString(pref.getValue("resultsView", "recent"));

String searchView = GetterUtil.getString(pref.getValue("searchView", "header"));

String advButtonName = "Advanced Search";
if(resultsView.equalsIgnoreCase("archive")){
	advButtonName = "Archive Search";
}

long resultsYear = GetterUtil.getLong(pref.getValue("resultsYear", "2017"));

String destination = GetterUtil.getString(pref.getValue("destination", ""));

boolean showRecent = resultsView.equalsIgnoreCase("recent");

String randomNamespace = PortalUtil.generateRandomKey(request, "portlet_search_bar") + StringPool.UNDERLINE;

SearchBarPortletDisplayContext searchBarPortletDisplayContextCustom = (SearchBarPortletDisplayContext)java.util.Objects.requireNonNull(request.getAttribute(WebKeys.PORTLET_DISPLAY_CONTEXT));


long userId=themeDisplay.getUserId();

long scropeGroupId = themeDisplay.getScopeGroupId();


//ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(com.liferay.portal.kernel.util.WebKeys.THEME_DISPLAY);

// List<AssetCategory> topic=getCategoryByVocabularyName(themeDisplay.getScopeGroupId(),"Topic"); //AssetCategoryFinderUtil.findByG_N(groupId, "Topic");
List<AssetCategory> project=getCategoryByVocabularyName(scropeGroupId,"Project");//AssetCategoryFinderUtil.findByG_N(groupId, "Project");
List<AssetCategory> contentType=getCategoryByVocabularyName(scropeGroupId,"Content Type");//AssetCategoryFinderUtil.findByG_N(groupId, "Content Type");
List<AssetCategory> classification=getCategoryByVocabularyName(scropeGroupId,"Classification");//AssetCategoryFinderUtil.findByG_N(groupId, "Content Type");
List<AssetCategory> recentYears = new ArrayList<AssetCategory>();
List<AssetCategory> archiveYears = new ArrayList<AssetCategory>();
for(AssetCategory assetCategory:classification){
	if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0 && assetCategory.getName().equalsIgnoreCase("Year")){
		for(AssetCategory assetChildCategory:AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId())){
			long yearCategory = GetterUtil.getLong(assetChildCategory.getName());
			if(yearCategory>=resultsYear){
				recentYears.add(assetChildCategory);
			}else {
				archiveYears.add(assetChildCategory);
			}

		}
	}
}

recentYears = recentYears.stream().sorted((a1, a2) -> a2.getName().compareTo(a1.getName())).collect(java.util.stream.Collectors.toList());
archiveYears = archiveYears.stream().sorted((a1, a2) -> a2.getName().compareTo(a1.getName())).collect(java.util.stream.Collectors.toList());
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

		<c:if test="<%= searchView.equalsIgnoreCase("header") %>">

			<aui:form action="javascript:void(0)" id="basicSearchFormHeader" method="get" name="fm" onSubmit="return basicSearchHeader();">


			<c:if test="<%= !Validator.isBlank(searchBarPortletDisplayContextCustom.getPaginationStartParameterName()) %>">
				<input class="search-bar-reset-start-page" name="<%= searchBarPortletDisplayContextCustom.getPaginationStartParameterName() %>" type="hidden" value="0" />
			</c:if>

			<aui:fieldset cssClass="search-bar">
				<aui:input cssClass="search-bar-empty-search-input" name="emptySearchEnabled" type="hidden" value="<%= searchBarPortletDisplayContextCustom.isEmptySearchEnabled() %>" />

				<div class="input-group <%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() ? "search-bar-scope" : "search-bar-simple" %>">
					<c:choose>
						<c:when test="<%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() %>">

						</c:when>
						<c:otherwise>
							<div  id="searchInputHeader" class="input-group-item search-bar-keywords-input-wrapper">
								<input class="form-control input-group-inset input-group-inset-after search-bar-keywords-input" data-qa-id="searchInputHeader" id="searchInputHeader"
								name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>"
								 placeholder="Search by Keyword, Tracking Number or Title"
								title="<%= LanguageUtil.get(request, "search") %>" type="text" value="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywords()) %>" />

								<aui:input name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getScopeParameterName()) %>" type="hidden" value="<%= searchBarPortletDisplayContextCustom.getScopeParameterValue() %>" />
								<div class="input-group-inset-item input-group-inset-item-after" onClick="basicSearchHeader();">
									<clay:button
									ariaLabel='<%= LanguageUtil.get(request, "submit") %>'
									icon="search"
									style="secondary"
									type="button"
								/>
								</div>
							</div>
						</c:otherwise>
					</c:choose>

					<c:if test="<%= searchView.equalsIgnoreCase("fullPage") %>">
						<span class="col-md-8"><a class="link-align" href="javascript:void(0);" id="<portlet:namespace/>displayAdv" > <i id="arrow-toggle-adv" class="icon-chevron-down"></i> <%=advButtonName %></a></span>
					</c:if>
				</div>
			</aui:fieldset>
		</aui:form>

		</c:if>
		<c:if test="<%= searchView.equalsIgnoreCase("fullPage") %>">
		<aui:form action="<%= String.valueOf(searchBarPortletDisplayContextCustom.getSearchURL()) %>" id="basicSearchForm" method="get" name="fm">

			<c:if test="<%= !Validator.isBlank(searchBarPortletDisplayContextCustom.getPaginationStartParameterName()) %>">
				<input class="search-bar-reset-start-page" name="<%= searchBarPortletDisplayContextCustom.getPaginationStartParameterName() %>" type="hidden" value="0" />
			</c:if>

			<aui:fieldset cssClass="search-bar">
				<aui:input cssClass="search-bar-empty-search-input" name="emptySearchEnabled" type="hidden" value="<%= searchBarPortletDisplayContextCustom.isEmptySearchEnabled() %>" />

				<div class="input-group <%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() ? "search-bar-scope" : "search-bar-simple" %>">
					<c:choose>
						<c:when test="<%= searchBarPortletDisplayContextCustom.isLetTheUserChooseTheSearchScope() %>">

						</c:when>
						<c:otherwise>
							<div  id="searchInput" class="col-md-4 input-group-item search-bar-keywords-input-wrapper">
								<input class="form-control input-group-inset input-group-inset-after search-bar-keywords-input" data-qa-id="searchInput" id="searchInput"
									name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywordsParameterName()) %>"
									placeholder="Search by Keyword, Tracking Number or Title" title="<%= LanguageUtil.get(request, "search") %>" type="text"
									value="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getKeywords()) %>" />

								<aui:input name="<%= HtmlUtil.escapeAttribute(searchBarPortletDisplayContextCustom.getScopeParameterName()) %>" type="hidden" value="<%= searchBarPortletDisplayContextCustom.getScopeParameterValue() %>" />
								<div class="input-group-inset-item input-group-inset-item-after">
									<button type="button" class="search-btn" onClick="javascript:basicSearch();">Search</button>
								</div>
							</div>
						</c:otherwise>
					</c:choose>

					<c:if test="<%= searchView.equalsIgnoreCase("fullPage") %>">
						<span class="col-md-8"><a class="link-align" href="javascript:void(0);" id="<portlet:namespace/>displayAdv" > <i id="arrow-toggle-adv" class="icon-chevron-down"></i> <%=advButtonName %></a></span>
					</c:if>
				</div>
			</aui:fieldset>
		</aui:form>

		<aui:form action="<%= searchBarPortletDisplayContextCustom.getSearchURL() %>" method="get" name="fm2" id="fm2">
		    <div id='<%= renderResponse.getNamespace() + "advanced-search-blueweb" %>' class="<%= showRecent ? "hide" : "" %>" >
            				 <div class="row search-layout menu-column">
            			      <table class="keywords-table col-md-12">
            			         <tr class="form-group">
            			            <td style="vertical-align: top;" class="form-group keywords1">
            			               <div>
            			                  <div>
            			                     <aui:input cssClass="form-control keyword-align" id="keyword1" placeholder='Keywords' inlineField="<%= true %>" style="width:100%;"
            			                      label="" name="keyword1" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("keyword1")) %>" title="Keywords" size="30" >
            			                      	<aui:validator errorMessage="Keyword required to filter search results." name="required"></aui:validator>
            			                      </aui:input>
            			                  </div>
            			               </div>
            			            </td>
            			            <td style="vertical-align: top;" class="form-group">
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
            			            <td style="vertical-align: top;" class="form-group">
            			               <div >
            			                  <div >
            			                     <input class="form-control keyword-align" id="keyword2" placeholder='Keywords' inlineField="<%= true %>" label=""
            			                      name="keyword3" title="Keywords" size="30" value="<%= printNotNull(PortalUtil.getOriginalServletRequest(request).getParameter("keyword2")) %>" />

            			                  </div>
            			               </div>
            			            </td>
            			            <td style="vertical-align: top;" class="form-group">
            			               <div >
            			                  <span><a class="link-align-basic hide" href="javascript:void(0);" id="<portlet:namespace/>displayBasic" > <i id="arrow-toggle-basic" class="icon-chevron-up"></i> Basic Search</a></span>
            			               </div>
            			            </td>
           			            </tr>
        			            <tr class="form-group">
            			            <td  style="vertical-align: top;" class="form-group">
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="category1" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Content Type" value="" />
            			                        <%for(AssetCategory assetCategory:contentType){ %>
            			                        <option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
            			                           for(AssetCategory childAssetCategory:childcategoryList){ %>
            			                        <option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
            			                           for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
            			                        <option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>"  <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category1"))) ? "selected" : ""%>/>
            			                        <%}}
            			                           %>
            			                        <%}}} %>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			            <td  style="vertical-align: top;" class="form-group">
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="category2" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Project" value="" />
            			                        <%for(AssetCategory assetCategory:project){ %>
            			                        <option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%> />
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
            			                           for(AssetCategory childAssetCategory:childcategoryList){ %>
            			                        <option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%>/>
            			                        <%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
            			                           List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
            			                           for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
            			                        <option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category2"))) ? "selected" : ""%> />
            			                        <%}}
            			                           %>
            			                        <%}}} %>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			            <td  style="vertical-align: top;" class="form-group">
            			               <div>
            			                  <div >
            			                     <label>Filter by :</label>
            			                  </div>
            			                  <div >
            			                     <select label="" name="category" id="category3" inlineField="<%= false %>" class="form-control filterQuery-align">
            			                        <option label="Year" value="" />
												<c:if test="<%= resultsView.equalsIgnoreCase("recent") %>">
													<%for(AssetCategory assetCategory:recentYears){ %>
													<option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
													<%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
													List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
													for(AssetCategory childAssetCategory:childcategoryList){ %>
													<option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%> />
													<%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
													List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
													for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
													<option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
													<%}}
													%>
													<%}}} %>
												</c:if>
												<c:if test="<%= resultsView.equalsIgnoreCase("archive") %>">
													<%for(AssetCategory assetCategory:archiveYears){ %>
													<option label="<%=assetCategory.getName()%>" value="<%=assetCategory.getCategoryId()%>" <%= (isMatched(assetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
													<%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(assetCategory.getCategoryId())>0){
													List<AssetCategory>	childcategoryList=AssetCategoryLocalServiceUtil.getChildCategories(assetCategory.getCategoryId());
													for(AssetCategory childAssetCategory:childcategoryList){ %>
													<option label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+childAssetCategory.getName()%>" value="<%=childAssetCategory.getCategoryId()%>" <%= (isMatched(childAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%> />
													<%if(AssetCategoryLocalServiceUtil.getChildCategoriesCount(childAssetCategory.getCategoryId())>0){
													List<AssetCategory>	subChildCategoryList=AssetCategoryLocalServiceUtil.getChildCategories(childAssetCategory.getCategoryId());
													for(AssetCategory subChildAssetCategory:subChildCategoryList){ %>
													<option class="italic-catg" label="<%=StringPool.DASH+StringPool.DASH+StringPool.SPACE+subChildAssetCategory.getName()%>" value="<%=subChildAssetCategory.getCategoryId()%>" <%= (isMatched(subChildAssetCategory.getCategoryId()+"", PortalUtil.getOriginalServletRequest(request).getParameter("category3"))) ? "selected" : ""%>/>
													<%}}
													%>
													<%}}} %>
												</c:if>
            			                     </select>
            			                  </div>
            			               </div>
            			            </td>
            			            <td class="form-group adv-search-buttons">
            			               <div>
            			                  <aui:button cssClass="btn-color" type="button" value="Clear" onClick="javascript:clearForm();"/>

            			                  <input type="hidden" name="advSearch" value="advSearch" />
            			                  <aui:button cssClass="search-btn" type="button" value="<%=advButtonName %>" onClick="javascript:search();"/>
            			               </div>
            			            </td>
            			         </tr>
            			      </table>
            			   </div>

            				</div>


		</aui:form>
		</c:if>
		<div class="yui3-skin-sam">
			<div id="modalConfirmation"></div>
		</div>


	</c:otherwise>
</c:choose>


<script>

    function clearForm(){
        /*window.location.href="<%= searchBarPortletDisplayContextCustom.getSearchURL() %>";*/
    	$("#<portlet:namespace />keyword1").val("");
    	$("#keyword2").val("");
    	$("#title").val("");
    	$("#trackingNumber").val("");
    	$("#operator").val("or");
    	$("#category1").val("");
    	$("#category2").val("");
    	$("#category3").val("");
    	$(".search-bar-keywords-input").val("");
    	window.history.pushState(null,null, window.location.pathname);
    }


    function basicSearchHeader(){
    	var tag = "<%= resultsView%>";

    	var portalURL = "<%=themeDisplay.getPortalURL()%>/web/fepoc<%= destination %>";

    	var searchInput = document.querySelector('input[id="searchInputHeader"]').value;

    	var query = "q="+searchInput;
        query = query +"&tag=<%=resultsView %>";

        window.location.href = portalURL + "?" + query;
        return false;
    }

    function basicSearch(){
    	var tag = "<%= resultsView%>";

    	var portalURL = "<%=themeDisplay.getPortalURL()%>/web/fepoc<%= destination %>";

    	var searchInput = document.querySelector('input[id="searchInput"]').value;


    	var query = "q="+searchInput;
        query = query +"&tag=<%=resultsView %>";

        window.location.href = portalURL + "?" + query;
    }

    function search(){

        var keyword1 = $("#<portlet:namespace />keyword1").val();
        if (keyword1 == "") {
            return false;
          }
        var keyword2 = $("#keyword2").val();
        var title = $("#title").val();
        var trackingNumber = $("#trackingNumber").val();

        var operand = $("#operator option:selected").val();
        var category1 = $("#category1 option:selected").val();
        var category2 = $("#category2 option:selected").val();
        var category3 = $("#category3 option:selected").val();

        var query = "";
        var searchQuery = "";
        if(isNotEmpty(keyword1) && isNotEmpty(operand) && isNotEmpty(keyword2)){
              searchQuery = getWithLogicalOperand(operand, keyword1, keyword2);
              query += "keyword1="+keyword1+"&keyword2="+keyword2+"&operator="+operand;
        } else if(isNotEmpty(keyword1)){
              searchQuery += keyword1;
              query += "keyword1="+keyword1;
        }else if(isNotEmpty(keyword2)){
            searchQuery += keyword2;
            query += "keyword2="+keyword2;
      	}
        if(isNotEmpty(title)){
           /*searchQuery += "title_<%=themeDisplay.getLanguageId()%>:"+ title;*/
            searchQuery += "+"+ title;
            query = appendMyString(query, "title", title);
        }
        if(isNotEmpty(searchQuery)){
           query = appendMyString(query, "q", searchQuery);
        }
        if(isNotEmpty(category1)){
           query = appendMyString(query, "category", category1);
           query = appendMyString(query, "category1", category1);
        }
        if(isNotEmpty(category2)){
           query = appendMyString(query, "category", category2);
           query = appendMyString(query, "category2", category2);
        }
        if(isNotEmpty(category3)){
           query = appendMyString(query, "category", category3);
           query = appendMyString(query, "category3", category3);
        }
        if(isNotEmpty(trackingNumber)){
           query = appendMyString(query, "trackingNumber", trackingNumber);
        }
        query += (isNotEmpty(query) ? "&" : "")+"search=advanced&tag=<%= resultsView%>";
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

	$(".portlet-layout.row.row2").css("background","#fff");
	<% if(PortalUtil.getOriginalServletRequest(request).getParameter("tag") != null || PortalUtil.getOriginalServletRequest(request).getParameter("q") != null) {%>
		$(".portlet-layout.row.row2").css("background","#EBEBEB");
	<% } %>
	<% if(PortalUtil.getOriginalServletRequest(request).getParameter("search") == null
        || !PortalUtil.getOriginalServletRequest(request).getParameter("search").equalsIgnoreCase("advanced")) {%>
		//$("#<portlet:namespace/>advanced-search-blueweb").addClass("hide");
		$("#arrow-toggle").toggleClass("icon-chevron-down icon-chevron-up");

	    $("#searchInput").removeClass("hide");
	    $("#<portlet:namespace/>displayAdv").removeClass("hide");
	    //$("#arrow-toggle").removeClass("icon-chevron-up icon-chevron-down");

	    $("#<portlet:namespace/>displayBasic").removeClass("hide");

	<% } else {%>

		$("#searchInput").addClass("hide");
		$("#<portlet:namespace/>displayAdv").addClass("hide");
		$("#<portlet:namespace/>displayBasic").removeClass("hide");
		$("#<portlet:namespace/>advanced-search-blueweb").removeClass("hide");
	<% }  %>

	<% if(themeDisplay.getURLCurrent().contains("archive")){%>
		$("#searchInput").addClass("hide");
		$("#<portlet:namespace/>displayBasic").addClass("hide");
		$("#<portlet:namespace/>displayAdv").addClass("hide");
	<%}%>

    $(".link-align").click(function(){
        $("#<portlet:namespace/>advanced-search-blueweb").toggleClass("hide");
        $("#searchInput").addClass("hide");

        //$("#arrow-toggle").toggleClass("icon-chevron-down icon-chevron-down");

        $("#<portlet:namespace/>displayBasic").removeClass("hide");
        $("#<portlet:namespace/>displayAdv").addClass("hide");

        $("#<portlet:namespace />keyword1").focus();
    });

    $(".link-align-basic").click(function(){
        $("#<portlet:namespace/>advanced-search-blueweb").addClass("hide");
        $("#searchInput").removeClass("hide");
        //$("#arrow-toggle").removeClass("icon-chevron-up icon-chevron-down");

        $("#<portlet:namespace/>displayBasic").addClass("hide");
        $("#<portlet:namespace/>displayAdv").removeClass("hide");
    });

    var searchInput = document.querySelector('input[id="searchInput"]').value;
	$("#<portlet:namespace />keyword1").val(searchInput);
	$("#<portlet:namespace />keyword1").focus();

});

</script>

<style>

#<portlet:namespace/>advanced-search-blueweb {
	padding:15px;
}

.adv-main-div{
	display:none;
	margin-top:-57px;
	margin-left: 35px;
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
.link-align,.link-align-basic{
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
/* #category2{
	width: 23rem;
}
#category3{
	width: 10rem;
}  */
.last-filterQuery{
	margin-bottom: 50px!important;
}
.searchcontainer-content{
	display:grid;
	/* padding:0 15px; */
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
/* .keyword-align{
	width:150px!important;
} */
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

/*.asset-entry-title .lexicon-icon.lexicon-icon-shortcut {
	height: 3rem;
    width: 3rem;
    margin-top: 10px;
	margin-left: 10px;
}*/
.asset-entry .asset-entry-title {
	font-size: 18px;
}
.asset-entry .text-default, .asset-entry .asset-entry-date {

	color: #1E1E1E;
}
.asset-entry .asset-entry-type {
	width:100px;
}

/* .row.search-layout.menu-column {
	width: 80%;
} */
.list-group-notification .list-group-item {
	background: #F9FAFA;
    border-bottom: 1px solid #ccc;
    border-top: 1px solid #ccc;
    box-shadow: none;
	border-radius:0;
}

.search-bar-keywords-input{
	height:4rem;
}
#searchInput {
	padding: 15px 30px;
	max-width: 65%;

}
/* .input-group.search-bar-simple {
	padding:15px 0;
} */
.panel-group {
	padding: 10px 0;
}

.icon-question-circle{
  padding-left: 15px;
  padding-top: 15px;
}

#modalConfirmation .yui3-widget-mask{
  z-index:10 !important;
}

#modalConfirmation .modal-dialog{
	z-index:100 !important;
}

.custom-control-label-text{
	font-size:15px;
}

.input-group-item .input-group-inset-after.form-control {
    border-top-right-radius: 5px;
    border-bottom-right-radius: 5px;
    border-right-width: 1px;
    padding-right: 5px;
}
#searchInput .input-group-inset-item-after{
    border-top-right-radius: 5px;
    border-bottom-right-radius: 5px;
    //width: 40px;
    height: 40px;
    background: #064D81 !important;
    border-radius: 5px;
    opacity: 1;
    margin-left:10px;

}
#searchInput .search-btn, .adv-search-buttons .search-btn{
	border: none;
    background: #064D81 !important;
    color: #fff !important;
    margin-right:0;
}
.adv-search-buttons .search-btn{
	width: 15rem;
}
.adv-search-buttons {
	vertical-align:bottom;

}
.adv-search-buttons .btn-color{
	margin-left:30px
}

.portlet-layout.row.row2{
/* 	background: #EBEBEB; */
	margin:0 20px !important;
	border-radius: 5px;
}

.lfr-panel.panel-default .panel-heading {
	border-radius: 5px;
}
.portlet-column-content.empty {
	padding:0px;
}

.search-facet .panel-body{
	background-color: #fff;
  		border: 1px solid #ccc;
	z-index: 9;
	position: absolute;
	width: 100%;
}
#searchInputHeader .btn.btn-secondary {
	color: #FFF;
    border-color: #00A6D2;
    background: #00A6D2;
}

.keywords1 .form-group.form-group-inline.input-text-wrapper {
	width:100%;
}

</style>
