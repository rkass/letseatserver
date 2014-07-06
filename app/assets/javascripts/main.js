var winWidth = $(window).width();
var winHeight = $(window).height();
var scrollTimeout = 0;

$(document).ready(function() {

	$("#sign-up-input").css("left", (winWidth - 200)/2);

	$(".page").each(function(i) {
		$(this).css("left", i * winWidth);
	});

	$("#prev-arrow-0, #next-arrow-2").on("click", function() {
		changePage($(this));
	});

	/*$(window).scroll(function() {
		clearTimeout(scrollTimeout);
		
		scrollTimeout = setTimeout(function() {
			var firstPos = 0;
			var currPos = $(document).scrollLeft();

			if (firstPos < currPos) {
				changePage($("#next-arrow-2"), currPos);
			} else {
				changePage($("#prev-arrow-0"), currPos);
			}
		}, 200);
	});*/

	$(document).on("keydown", function(e) {
		if (e.keyCode == 37)
			changePage($("#prev-arrow-0"));
		else if (e.keyCode == 39)
			changePage($("#next-arrow-2"));
	});

	$(".circle").on("click", function() {
		var $currPage = $(".selected-page");
		var currPageNumber = $(".selected-circle").attr("id").split("-")[1];
		var nextPageNumber = Number($(this).attr("id").split("-")[1]);
		
		var currPageID = $(".selected-page").attr("id").split("-")[1];
		var nextPageID = $(".page-"+nextPageNumber).attr("id").split("-")[1];
		var numPageChange = nextPageID - currPageID;

		$(".selected-circle").removeClass("selected-circle");
		$("#circle-"+nextPageNumber).addClass("selected-circle");

		$("#page-"+nextPageID)
			.addClass("selected-page");
			
		$(".page").each(function() {
			$(this).animate({
				left: "-="+winWidth*numPageChange
			}, function() {
				if (numPageChange != 0) $currPage.removeClass("selected-page");
			});
		});

		if (nextPageID == 1) {
			$(".screenshot").each(function(i) {
				console.log(i, Number(nextPageNumber));
				if (i < Number(nextPageNumber)) {
					$(this).css("opacity", "1")
						.addClass("display-screenshot");
				} else {
					$(this).css("opacity", "0")
						.removeClass("display-screenshot");
				}
			});

			$(".display-screenshot").each(function(i) {
				$(this).css("right", 50 * ($(".display-screenshot").length - i - 1));
			});

			$(".display-text").removeClass("display-text");
				$("#about-text-"+nextPageNumber).addClass("display-text");
		} else if (nextPageID == 0) {
			$(".display-screenshot")
				.not("#screenshot-0")
				.removeClass("display-screenshot")
				.css("opacity", 0);
			$(".screenshot").css("right", 0);
		}

		isLastPage();
		isFirstPage();
	});
	
	$("#sign-up-button").on("click", function() {
		if ($("#sign-up-input").css("display") == "none") {
			$("#sign-up-input").val("")
				.show()
				.animate({
					width: "193"
				}, 300)
				.focus();
		} else {
			$("#sign-up-input").animate({
					width: "1"
				}, 300, function() {
					$("#sign-up-input").hide();
			});	
		}
	});

	$(document).on("keydown", "#sign-up-input", function(e) {
		if(e.keyCode == 13 && $("#sign-up-input").val().length > 0) {

		}
	});

	containerHeight = winHeight - $("#blue-strip").height() - $("#footer").height();
	$(".screenshot").css("top", (containerHeight - $(".screenshot").height()) / 2);

});

function isLastPage() {
	if ($(".selected-circle").attr("id").split("-")[1] == $(".circle").length - 1) {
		$("#next-arrow-2").css("opacity", .1);
		$("#next-arrow-2").removeClass("clickable");
	} else if (Math.round($("#next-arrow-2").css("opacity")) == 0){
		$("#next-arrow-2").css("opacity", "1");
		$("#next-arrow-2").addClass("clickable");
	}
}

function isFirstPage() {
	if ($(".selected-circle").attr("id").split("-")[1] == 0) {
		$("#prev-arrow-0").css("opacity", .1);
		$("#prev-arrow-0").removeClass("clickable");
	} else if (Math.round($("#prev-arrow-0").css("opacity")) == 0){
		$("#prev-arrow-0").css("opacity", "1");
		$("#prev-arrow-0").addClass("clickable");
	}
}

function changePage(element, scrollAmt) {
	if (Math.round($(element).css("opacity")) != 0) {
			$currPage = $(".selected-page");
			var currPageNumber = Number($(".selected-circle").attr("id").split("-")[1]);
			var nextPageNumber = currPageNumber + Number($(element).attr("id").split("-")[2] - 1);
			var numPageChange = nextPageNumber - currPageNumber;

			if ( nextPageNumber == 0 || nextPageNumber == 4 || (currPageNumber == 4 && nextPageNumber == 3) || (currPageNumber == 0 && nextPageNumber == 1) ) {
				$(".page-"+nextPageNumber)
					.addClass("selected-page");

				$(".page").each(function() {
					$(this).animate({
						left: "-="+winWidth*numPageChange
					}, function() {
						$currPage.removeClass("selected-page");
					});
				});

			} else {
				$(".display-screenshot").animate({
					right: "+="+50*numPageChange
				}, 250, function() {
					if (numPageChange > 0) {
						$("#screenshot-"+currPageNumber).animate({
							opacity: 1
						}, 250)
						.addClass("display-screenshot");
					} else {
						$(".screenshot").each(function(i) {
							if (i >= currPageNumber - 1) {
								$(this).animate({
									opacity: 0
								}, 250, function() {
									$(this).css("right", "0px");
								})
								.removeClass("display-screenshot");
							}
						});
					}
				});

				$(".display-text").removeClass("display-text");
				$("#about-text-"+nextPageNumber).addClass("display-text");
			}

			$(".selected-circle").removeClass("selected-circle");
			$("#circle-"+nextPageNumber).addClass("selected-circle");

			isLastPage();
			isFirstPage();
		}
}



