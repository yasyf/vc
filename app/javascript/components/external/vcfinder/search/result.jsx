import React from 'react';

const Photo = ({photo, initials}) => {
  if (photo) {
    return (
      <img
        className="search-photo"
        src={photo}
      />
    );
  } else {
    return (
      <img
        className="search-photo"
        src={`http://via.placeholder.com/75x75/e6e6e6?text=${initials}`}
      />
    );
  }
};

const SearchResult = (props) => {
  return (
    <div className="row search-item">
      <div className="small-1 columns">
        <Photo {...props} />
      </div>
      <div className="small-11 columns">
        {props.first_name} {props.last_name}
        <br/>
        {props.role ? `${props.role}, ` : ''}{props.competitor.name}
      </div>
    </div>
  );
};

export default SearchResult;