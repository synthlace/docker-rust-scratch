use rocket;

#[rocket::get("/")]
fn index() -> &'static str {
    "Hello, Docker!"
}

#[rocket::launch]
fn run() -> _ {
    rocket::build().mount("/", rocket::routes![index])
}
