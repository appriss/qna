function submit_vote (type, obj, vote) {
	var parent_sel = "";
	if (type == "answer") parent_sel = "article.answer";
	if (type == "question") parent_sel = "section#question";

	var parent = obj.parents(parent_sel).eq(0);
	var vote_count = $('.vote-count-post', parent);
	var dir = vote == 1 ? "up" : "down";
	var other_dir = vote == 1 ? "down" : "up"
	var other_vote = $('.vote-'+other_dir, parent);
	var url = parent.attr("vote_url");
	var data = {}

	if (vote == 1) data["vote_up"] = 1
	if (vote == -1) data["vote_down"] = -1

	$.post(url+".json", data).success(function () {
		if (obj.hasClass('vote-'+dir+'-on')) {
			obj.removeClass('vote-'+dir+'-on');
			vote_count.html(parseInt(vote_count.html()) + -vote);
		} else {
			obj.addClass('vote-'+dir+'-on');
			vote_count.html(parseInt(vote_count.html()) + vote);
		}

		if (other_vote.hasClass('vote-'+other_dir+'-on')) {
			other_vote.removeClass('vote-'+other_dir+'-on');
			vote_count.html(parseInt(vote_count.html()) + vote);
		}
	});
}

function delete__comment (comment) {
	var data_url = comment.attr("data-url");
	var comment_id = comment.attr("data-comment-id");
	$.ajax({
		async: true,
		type: 'delete',
		url: data_url + ".json"
	});
	$('#'+comment_id).hide('fast');
}

$(document).ready(function() {
	var $body = $(document.body);
	Loader.initialize($body, true);

	$('.comment-delete').click(function () {
		delete__comment($(this));
	});

	$('article.answer a.vote-up').click(function () {
		submit_vote("answer", $(this), 1);
	});
	$('article.answer a.vote-down').click(function () {
		submit_vote("answer", $(this), -1);
	});

	$('section#question a.vote-up').click(function () {
		submit_vote("question", $(this), 1);
	});
	$('section#question a.vote-down').click(function () {
		submit_vote("question", $(this), -1);
	});

	$('section#question a.star').click(function () {
		var obj = $(this);
		var parent = obj.parents('section#question').eq(0);
		var count = $('.favoritecount', parent).eq(0);
		var url = parent.attr("question_url");
		url += obj.hasClass('star-on') ? "/unfollow" : "/follow";
		var datetime = new Date();
		$.get(url+".json");
		if (obj.hasClass('star-on')) {
			obj.removeClass('star-on');
			obj.addClass('star-off');
			count.html(parseInt(count.html()) - 1);
		} else {
			obj.removeClass('star-off');
			obj.addClass('star-on');
			count.html(parseInt(count.html()) + 1);
		}
	});
});
