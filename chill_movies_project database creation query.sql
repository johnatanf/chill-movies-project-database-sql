CREATE DATABASE chill_movies_project;
USE chill_movies_project;

CREATE TABLE parental_rating (
	parental_rating_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    rating_name VARCHAR(50)
);

CREATE TABLE actor (
	actor_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    actor_name VARCHAR(255)
);

CREATE TABLE director (
	director_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    director_name VARCHAR(255)
);

CREATE TABLE genre (
	genre_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    genre_name VARCHAR(255)
);

CREATE TABLE subscription (
	subscription_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    plan_name VARCHAR(50) NOT NULL,
    price_month DECIMAL(10, 2) NOT NULL,
	number_of_accounts INT NOT NULL
);

CREATE TABLE subscription_feature (
	subscription_feature_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    subscription_id INT NOT NULL,
    feature_description VARCHAR(255) NOT NULL,
	CONSTRAINT fk_subscription_feature_table_subscription_id
    FOREIGN KEY (subscription_id) REFERENCES subscription(subscription_id)
);

CREATE TABLE content (
	content_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    parental_rating_id INT,
    title VARCHAR(255) NOT NULL,
    content_description TEXT NOT NULL,
    description_image_url TEXT NOT NULL,
    thumbnail_image_url TEXT NOT NULL,
    content_type ENUM ('Movie', 'Series'),
    chill_original BOOLEAN NOT NULL,
    premium BOOLEAN NOT NULL,
    duration_minutes INT NULL,
    release_date DATE NOT NULL,
    CONSTRAINT fk_content_table_parental_rating_id
    FOREIGN KEY (parental_rating_id) REFERENCES parental_rating(parental_rating_id),
    CONSTRAINT duration_only_for_movie
    CHECK ( (content_type = 'Series' AND duration_minutes IS NULL) OR (content_type = 'Movie' AND duration_minutes IS NOT NULL) )
);

CREATE TABLE season (
	season_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    content_id INT NOT NULL,
    season_number INT NOT NULL,
    release_date DATE NOT NULL,
    season_description TEXT,
    CONSTRAINT fk_season_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id)
);

CREATE TABLE episode (
	episode_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    season_id INT NOT NULL, 
    episode_number INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    episode_description TEXT NOT NULL,
    release_date DATE NOT NULL,
    duration_minutes INT NULL,
	CONSTRAINT fk_season_id
    FOREIGN KEY (season_id) REFERENCES season(season_id)
);

CREATE TABLE user_account (
	user_account_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    avatar_image_url TEXT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(255) NOT NULL
);

CREATE TABLE rating (
	rating_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    content_id INT NOT NULL,
    rating_value INT NOT NULL,
    rating_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rating_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    CONSTRAINT check_rating_value
    CHECK (rating_value >= 1 AND rating_value <= 5)
);

CREATE TABLE voucher (
	voucher_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    voucher_code VARCHAR(50) NOT NULL,
    discount_percentage DECIMAL(3, 2) NOT NULL,
    expiration_date DATE NOT NULL,
    current_uses INT NOT NULL,
    is_active BOOLEAN NOT NULL,
    CONSTRAINT check_discount_percentage
    CHECK (discount_percentage >= 0 AND discount_percentage <= 1)
);

CREATE TABLE payment_method (
	payment_method_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    payment_method_name VARCHAR(255) NOT NULL,
    payment_method_description VARCHAR(255) NOT NULL
);

CREATE TABLE payment (
	payment_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    user_account_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_code VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) NOT NULL, # id returned by 3rd party payment gateway,
    payment_status ENUM ('Pending', 'Success', 'Failed', 'Refunded', 'Cancelled') DEFAULT 'Pending',
	CONSTRAINT fk_payment_table_user_account_id
    FOREIGN KEY (user_account_id) REFERENCES user_account(user_account_id),
    CONSTRAINT fk_payment_table_payment_method_id
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id)
);

CREATE TABLE content_actor (
    content_id INT NOT NULL,
    actor_id INT NOT NULL,
    PRIMARY KEY (content_id, actor_id),
    CONSTRAINT fk_content_actor_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    CONSTRAINT fk_content_actor_table_actor_id
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
);

CREATE TABLE content_director (
    content_id INT NOT NULL,
    director_id INT NOT NULL,
    PRIMARY KEY (content_id, director_id),
    CONSTRAINT fk_content_director_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    CONSTRAINT fk_content_director_table_director_id
    FOREIGN KEY (director_id) REFERENCES director(director_id)
);

CREATE TABLE content_genre (
    content_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (content_id, genre_id),
    CONSTRAINT fk_content_genre_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    CONSTRAINT fk_content_genre_table_genre_id
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE user_account_subscription (
    user_account_id INT NOT NULL,
    subscription_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (user_account_id, subscription_id),
    CONSTRAINT fk_user_account_subscription_table_user_id
    FOREIGN KEY (user_account_id) REFERENCES user_account(user_account_id),
    CONSTRAINT fk_user_account_subscription_table_subscription_id
    FOREIGN KEY (subscription_id) REFERENCES subscription(subscription_id)
);

CREATE TABLE watch_history (
    user_account_id INT NOT NULL,
    content_id INT NOT NULL,
    progress DECIMAL(3, 2) NOT NULL, #how many percent the content is watched
    PRIMARY KEY (user_account_id, content_id),
    CONSTRAINT fk_watch_history_table_user_account_id
    FOREIGN KEY (user_account_id) REFERENCES user_account(user_account_id),
    CONSTRAINT fk_watch_history_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id),
    CONSTRAINT check_progress
    CHECK (progress >= 0 AND progress <= 1)
);

CREATE TABLE watch_list (
    user_account_id INT NOT NULL,
    content_id INT NOT NULL,
    date_added DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (user_account_id, content_id),
    CONSTRAINT fk_watch_list_table_user_account_id
    FOREIGN KEY (user_account_id) REFERENCES user_account(user_account_id),
    CONSTRAINT fk_watch_list_table_content_id
    FOREIGN KEY (content_id) REFERENCES content(content_id)
);