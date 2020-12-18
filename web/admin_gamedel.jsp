<%@page import="dao.GameDao"%>
<%@page import="common.*"%>

<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_GAMEMNG);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesi�n!");
        response.sendRedirect("account_login.jsp");
        return;
    }
    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_STOREMANAGER_LOWER)) {
        errmsg = "No tienes autorizaci�n para gestionar juegos!";
    }

    if (errmsg.isEmpty()) {
        String gamekey = request.getParameter("gamekey");

        GameDao dao = GameDao.createInstance();
        if (dao.isExisted(gamekey)) {
            dao.deleteGame(gamekey);
            response.sendRedirect("admin_gamelist.jsp");
        } else {
            errmsg = "No game found!";
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div>
        <h3>Eliminar Juegos</h3>
        <h3 style='color:red'>${errmsg}</h3>    
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />
