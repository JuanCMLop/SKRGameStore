<%@page import="common.*"%>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />

<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_HOME);
%>
<jsp:include page="layout_menu.jsp" />
<img class="header-image" src="images/site/banner.png" alt="Games" />

<section id="content">
    <div class="post">
        <h3 class="title">Bienvenido a SKRGame Store</h3>
        <div class="entry">
            <img src="images/site/portada_4.jpg" style="width: 600px; display: block; margin-left: auto; margin-right: auto" />
            <br>
            <h2>Nuestros clientes confían en nosotros para brindar un servicio rápido, para los fanáticos de los videojuegos</h2>
            <br>
            <h3>Vencimos a nuestros competidores en todos los aspectos. Precio de oferta garantizado!!!</h3>
        </div>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />
