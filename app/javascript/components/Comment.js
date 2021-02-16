import React from "react";
import PropTypes from "prop-types";

class Comment extends React.Component {
  render() {
    let authorSection = [];
    if (this.props.comment.author) {
      const authorProfilePic = (this.props.comment.author.photo_file_name) ?
        <img
          className="rounded-circle"
          alt="Comment Author Profile Picture"
          src={this.props.comment.author.photo_path.thumb}
          style={{
            marginRight: "6px",
            width: "32px"
          }}
        /> :
        <div
          className="rounded-circle"
          style={{
            background: "#ccc",
            display: "inline-block",
            height: "32px",
            marginRight: "6px",
            verticalAlign: "middle",
            width: "32px"
          }}
        />;
      const authorName = (this.props.comment.author.name) ?
        <a href={"/profile/" + this.props.comment.author.name}>
          {this.props.comment.author.name}
        </a> :
        this.props.comment.name;
      authorSection.concat([authorProfilePic, authorName]);
    }

    return (
      <div
        id={"c" + this.props.comment.cid}
        className="comment"
        style={{
          marginTop: "20px",
          marginBottom: "20px",
          paddingBottom: "9px",
          wordWrap: "break-word"
        }}
      >
        <div
          className="bg-light navbar navbar-light"
          style ={{
            borderBottom: 0,
            borderBottomLeftRadius: 0,
            borderBottomRightRadius: 0,
            marginBottom: 0
          }}
        >
          {/* placeholder: moderator controls for approving comments from first-time posters */}
          <div className="navbar-text float-left d-md-none">&nbsp;&nbsp;</div>
          <div className="navbar-text float-left">
            {authorSection}
            {/* placeholder: user commented text */}
          </div>
          <div
            className="navbar-text float-right"
            style={{
              marginRight: 0,
              paddingRight: "10px"
            }}
          >

          </div>
          {this.props.comment.commentText}
        </div>
      </div>
    );
  }
}

Comment.propTypes = {
  comment: PropTypes.object
};

export default Comment;
