$(document).ready(function () {

    // uruchomienie opcji dostepnych tylko dla js

    $('.panel-collapsem').removeClass('hidden');
    $('.panel-criteria').addClass('hidden');
    //uruchomienie w advancedDisamb
    $('.sidebar-hidden_f, .list-hidden_f').addClass('hidden');
    $('.expand-icon_f').removeClass('hidden');
    $("#advanced_search_info_panel").addClass("hidden"); //KN

    $('.panel-collapse').click(function () {
        var criteria = $(this).closest('.panel-criteria').attr('id');
        $(this).closest('.panel-criteria').addClass('hidden');
        $('.criteria-btn[href=#' + criteria + ']').removeClass('success');

        //Usunięcie minusa oraz wyczyszczenie pól
        $('.criteria-btn[href=#' + criteria + ']').find(".fa").removeClass("fa-minus-circle").addClass("fa-plus-circle");
        var $this = $(this);
        $this.closest(".panel").find("select option[value='']").prop("selected", true); 
        $this.closest(".panel").find("input").val("");
        $this.closest(".panel").find(".clone-this-content_f:not(:first)").remove();
    });
    //Schowanie wszystkich elementów na liście
    $(".entry_simple_sense").toggle(); //Dodałem li[level!=0]
    
    $("fieldset>.entry_simple_sense").toggle();
    
    $(".entry_simple_sense").closest("li").find(" > span.expand-block>.fa.fa-plus-square").removeClass("hidden");

    //Anomalia
    $(".anomale").toggle();
    
    $(document).on("click", ".anomale-expand", function () {
       $(".anomale").toggle();
    });

    $(".solid-height").removeClass("hidden");
    //Expand znaczenia pełne hasło wymagane
    //$(".sense").toggle();
    $(".entry-section.sense").toggle();
    $(".sense").parent(".sense").prepend('<i class="fa fa-minus-square expand-next-sense_f"></i>');

    //Collapse w panelu
    $(".js-remove-hidden_f").removeClass("hidden");
    $(".js-add-hidden_f").addClass("hidden");

    // KN: Wyszukiwanie zaawansowane: ukrywanie info
    $("#advanced_info").click(function (event) {
        event.preventDefault();
        if  ( $("#advanced_search_info_panel").hasClass('hidden') ) {
            $("#advanced_search_info_panel").removeClass("hidden");
            }
        else { $("#advanced_search_info_panel").addClass("hidden"); }
        
    });
    
    
    // akcje w advancedBrowse
    $('.criteria-btn').click(function (event) {
        event.preventDefault();
        var criteria = $(this).attr('href');
        if ($(this).hasClass('success')) {
            $(criteria).addClass('hidden');
            $(criteria).find(":selected").prop("selected",false)//KN: zerowanie pól
            $(this).removeClass('success');
        } else {
            $(criteria).removeClass('hidden');
            $(this).addClass('success');
        }

    });

    // akcje w advancedDisamb
    $('.expand-next-sidebar_f').click(function (event) {
        event.preventDefault();
        var $this = $(this);

        $this.closest('h4').next().toggleClass("hidden");
    });

    $('.expand-next-list_f').click(function (event) {
        event.preventDefault();
        var $this = $(this);

        $this.find('.fa').toggleClass("hidden");
        $this.closest('li').next().toggleClass("hidden");
    });

    $('.check-next-list_f').click(function (event) {
        //        event.preventDefault();
        var $this = $(this);

        if ($this.prop("checked")) {
            $this.closest('li').next().find("[type='checkbox']").prop("checked", true);
        } else {
            $this.closest('li').next().find("[type='checkbox']").prop("checked", false);
        }
    });
    
    /* index.html */
    /* Pole sugestii - duże */
    $('#main_search_field').autocomplete({
        autofocus: true,
        delay: 300,
        minLength: 3,
        source: function (request, response) {
            $.ajax({
                url: "lemmaLookup.xql",
                dataType: "json",
                data: {
                    term: request.term
                },
                success: function (data) {
                    var data_array = $.makeArray(data.result); //Tworzy array na potrzeby 1 wyniku
                    var array =  $.map(data_array,function(obj) {
                        return {
                            label : obj.label,
                            value : obj.value
                        };
                    })
                    response (array);
                    console.log( array );
                    console.log (data);
                    
                }
                /* brak odpowiedzi*/
                /*,
                error: response(null)*/
            
            })
            ;
        },
        select: function (event, ui) {
            /* Tworzy link do hasła, wykorzystując identyfikator "value" */
            /*window.location.href = "./singleView.html?what=" + ui.item.value;*/
            window.location.href = "./lemma/" + ui.item.value;
        }
       
    });
    /*Sprawdź, czy obiekt odpowiedzi istnieje na stronie: jeśli tak, dodaj style */
    if ( $('#main_search_field').data('ui-autocomplete') ) {
    $('#main_search_field').data('ui-autocomplete')._renderItem = function (ul,item) {
        if (item.label !== item.value) {var lemmaLink = "<a>" + 
                "<span class=\"alert label form-label\">wyraz</span>" + " " + 
                    item.label +
                    "<i class=\"fa fa-arrow-right entry-pointer\"/>" +
                    
                "<span class=\"label entry-label\">hasło</span>" + " " + 
                    item.value +
          "</a>"} else {var lemmaLink =
              "<a>" + 
                "<span class=\"alert label form-label\">wyraz</span>" + " " + 
                    item.label +
          "</a>"
          };
        return $("<li>")
        .append(lemmaLink)
        .appendTo( ul );
        console.log(ul);
    };
    };
     /* Pole sugestii - małe */
    $('#nav_search_field').autocomplete({
        autofocus: true,
        delay: 300,
        minLength: 3,
        source: function (request, response) {
            $.ajax({
                url: "lemmaLookup.xql",
                dataType: "json",
                data: {
                    term: request.term
                },
                success: function (data) {
                    var array =  $.map(data.result,function(obj,i) {
                        return {
                            label : obj.label,
                            value : obj.value
                        };
                    })
                    response (array);
                    console.log( array );
                    console.log (data);
                    
                }
            })
            ;
        },
        select: function (event, ui) {
            /* Tworzy link do hasła, wykorzystując identyfikator "value" */
            window.location.href = "./lemma/" + ui.item.value;
            /*window.location.href = "./singleView.html?what=" + ui.item.value;*/
        }
       
    }).data('ui-autocomplete')._renderItem = function (ul,item) {
        return $("<li>")
        .append("<a>" + "<small>" + item.label + "</small>" + "</a>")
        .appendTo( ul );
        console.log('jestem');
    };

    /* Fontes: przesyłanie formy */
    
    $("form input[type = 'submit']").toggleClass("hide button");
    var timer = null;
    $("#filter_siglum,#filter_auctor,#filter_titulus,#filter_genus").on('input', function (event) {
        function searchFons (event) {
            var siglum = $("#filter_siglum").val();
            var auctor = $("#filter_auctor").val();
            var titulus = $("#filter_titulus").val();
            var genus = $("#filter_genus").val();
            var form = $("#filter_form").serialize()
            console.log(event);
        
            $.post('fontes_lookup.xql', form, function (data) {
                $("#fontes_container")
                    .html(data);
                console.log(event);
            });
        }
        if (timer) {
            clearTimeout (timer);
        }
        timer = setTimeout ( searchFons , 250)
        

    });

    //Expand buttons
    $(document).on("click", ".expand-block", function () {
        var $this = $(this);
        if ($this.find("i").hasClass("fa-plus-square") && $this.closest("li").find(" > .entry_simple_sense").length > 0) {
            $this.find("i").removeClass("fa-plus-square").addClass("fa-minus-square");
        } else if ($this.closest("li").find(" > .entry_simple_sense").length > 0) {
            $this.find("i").removeClass("fa-minus-square").addClass("fa-plus-square");
        }

        $this.closest("li").find(" > .entry_simple_sense").toggle();
    });

    //Expand pełne hasło
    $(document).on("click", ".expand-next-sense_f", function () {
        var $this = $(this);
        if ($this.hasClass("fa-plus-square")) {
            $this.removeClass("fa-plus-square").addClass("fa-minus-square");
        } else {
            $this.removeClass("fa-minus-square").addClass("fa-plus-square");
        }
        $(this).closest(".sense").find(" > .sense, > .note .sense").toggle();
    });

    //Zmiana ikon plus/minus w guzikach Advanced Browse
    $(document).on("click", ".criteria-btn", function () {
        var $this = $(this);
        var icon = $this.find(".fa");
        if (icon.hasClass("fa-plus-circle")) {
            icon.removeClass("fa-plus-circle");
            icon.addClass("fa-minus-circle");
        } else {
            icon.addClass("fa-plus-circle");
            icon.removeClass("fa-minus-circle");
        }
    });
    

    //KN: Morfologia Advanced Browse
    /*$(document).on("change", "[name='gram_pos']", function () {
        var $this = $(this);
        if ($this.find("option:selected").val() == "n") {
            if ($this.closest(".row").find("#gram_itype,#gram_gen").hasClass("hidden")) {
                $this.closest(".row").find("#gram_itype,#gram_gen").removeClass("hidden");
            }
        } else {
            if (!$this.closest(".row").find("#gram_itype,#gram_gen").hasClass("hidden")) {
                $this.closest(".row").find("#gram_itype,#gram_gen").addClass("hidden");
            }
        }
    });*/

    //Zablokowanie szukania gdy użytkownik nic nie wpisał
    $(document).on("click", "#advanced_search_submit", function (event) {
        if ( $("input#advanced_search_field").val() == ""  && $("#criteria_morpho :input[value != '' ]").val() == "" && $("#criteria_etymon  :input[value != '' ]").val() == ""  && $("#criteria_sense  :input[value != '' ]").val() == "" && $("#criteria_citation  :input[value != '' ]").val() == "" ) {
            event.preventDefault();
            $(".empty-search-alert_f").removeClass("hidden");
        }
    });

    //Kopiowanie fieldsetu
    $(document).on("click", ".copy-fieldset_f", function () {
        var $this = $(this);

        var $clone = $this.closest("fieldset").find(".clone-this-content_f:last").clone();
        $this.closest("fieldset").find(".delete-content_f").removeClass("hidden");
        $clone.find(".delete-content_f").removeClass("hidden");
        $this.before($clone);
    });

    //Usuwanie skopiowanego
    $(document).on("click", ".delete-content_f", function () {
        var $this = $(this);
        if ($this.closest("fieldset").find(".clone-this-content_f").length > 1) {
            $this.closest(".clone-this-content_f").remove();
        } else {
            $this.closest("fieldset").find("select option[value='']").prop("selected", true);
            $this.closest("fieldset").find("input").val("");
        }
    });
});