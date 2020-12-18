<%@page import="common.*"%>
<%@page import="dao.*"%>
<%@page import="beans.*"%>
<%@page import="java.util.*"%>




<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    String errmsg = "";
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_HOME);

    String productkey = request.getParameter("productkey");
    String rating = "";
    String reviewtext = "";

    if (productkey == null || productkey.isEmpty()) {
        errmsg = "Par�metro no v�lido. No se puede encontrar el producto: " + productkey;
    } else {
        ProductDao dao = ProductDao.createInstance();

        if ("GET".equalsIgnoreCase(request.getMethod())) {

        } else {
            if (!helper.isLoggedin()) {
                session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesi�n!");
                response.sendRedirect("account_login.jsp");
                return;
            }

            ProductItem product = dao.getProduct(productkey);
            if (product == null) {
                errmsg = "No existe el producto: " + productkey;
            } else {
                rating = request.getParameter("rating");
                reviewtext = request.getParameter("reviewtext");
                if (rating != null && reviewtext != null) {
                    Review newreview = new Review(helper.generateUniqueId(), productkey, helper.username(), Integer.parseInt(rating), new Date(), reviewtext);
                    //product.getReviews().add(0, newreview);
                    switch (product.getType()) {
                        case 1:
                            ConsoleDao consoleDao = ConsoleDao.createInstance();
                            consoleDao.addConsoleReview(product.getId(), newreview);
                            break;
                        case 2:
                            ConsoleDao consoleDao2 = ConsoleDao.createInstance();
                            consoleDao2.addAccessoryReview(product.getConsole(), product.getId(), newreview);
                            break;
                        case 3:
                            GameDao gameDao = GameDao.createInstance();
                            gameDao.addGameReview(product.getId(), newreview);
                            break;
                        case 4:
                            TabletDao tabletDao = TabletDao.createInstance();
                            tabletDao.addTabletReview(product.getId(), newreview);
                            break;
                    }
                }
            }
        }

        ProductItem product = dao.getProduct(productkey);
        List<Review> list = product.getReviews();
        pageContext.setAttribute("list", list);
        pageContext.setAttribute("product", product);
        pageContext.setAttribute("errmsg", errmsg);
    }
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div class="post">
        <h3 class="title">Revisi�n del Producto</h3>
        <h3 style='color:red'>${errmsg}</h3>
        <div class="entry">
            <h2>${product.name}</h2>
            <img src="images/${product.image}" style="width: 300px;" />
            <br>
            <hr>
            <h5>Enviar sus Comentarios</h5>
            <form action='review.jsp' method='POST'>
                <input type='hidden' name='productkey' value='${product.id}'>
                <table>
                    <tr><td>Calificaci�n:</td><td><select name='rating' class='input'><option value='5' selected>5</option><option value='4'>4</option><option value='3'>3</option><option value='2'>2</option><option value='1'>1</option></select></td></tr>
                    <tr><td>Comentarios:</td><td><textarea name="reviewtext" rows="5" cols="50"></textarea></td></tr>
                    <tr><td></td><td><input type='submit' class='formbutton' value='Enviar'></td></tr>
                </table>        
            </form>
            <hr>
            <c:choose>
                <c:when test="${list.size() == 0}">
                    <h3>0 Comentarios</h3>
                    <hr style="border-top: dotted 1px;" />
                </c:when>
                <c:otherwise>
                    <h3><c:out value="${list.size()}"/> Comments</h3>
                    <hr style="border-top: dotted 1px;" />
                    <c:forEach var="review" items="${list}">
                        <table cellspacing='0'>
                            <tr><td><b><c:out value="${review.userName}"/></b></td><td><fmt:formatDate pattern="yyyy-MM-dd hh:mm:ss" value="${review.reviewDate}" /></td></tr>
                            <tr><td>Calificaci�n:</td><td><c:out value="${review.rating}"/></td></tr>
                            <tr><td>Comentarios:</td><td><c:out value="${review.reviewText}"/></td></tr>
                            <tr><td colspan="2"></td></tr>
                        </table>                
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />