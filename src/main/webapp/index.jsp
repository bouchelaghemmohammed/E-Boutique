<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Redirige vers /accueil qui lui-même dispatche vers dashboard ou connexion --%>
<% response.sendRedirect(request.getContextPath() + "/accueil"); %>
